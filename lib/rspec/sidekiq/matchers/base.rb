# frozen_string_literal: true

module RSpec
  module Sidekiq
    module Matchers
      # @api private
      class JobOptionParser
        attr_reader :job

        def initialize(job)
          @job = job
        end

        def matches?(options)
          with_context(**options)
        end

        private

        def at_evaluator(value)
          return value.nil? if job["at"].to_s.empty?
          value == Time.at(job["at"]).to_i
        end

        def with_context(**expected_context)
          expected_context.all? do |key, value|
            if key == "at"
              # send to custom evaluator
              at_evaluator(value)
            else
              job.context.has_key?(key) && job.context[key] == value
            end
          end
        end
      end

      # @api private
      class JobArguments
        include RSpec::Mocks::ArgumentMatchers

        def initialize(job)
          self.job = job
        end
        attr_accessor :job

        def matches?(expected_args)
          matcher = RSpec::Mocks::ArgumentListMatcher.new(*expected_args)

          matcher.args_match?(*unwrapped_arguments)
        end

        def unwrapped_arguments
          args = job["args"]

          return deserialized_active_job_args if active_job?

          args
        end

        private

        def active_job?
          if RSpec::Sidekiq.configuration.sidekiq_gte_8?
            job["class"] == "Sidekiq::ActiveJob::Wrapper"
          else
            job["class"] == "ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper"
          end
        end

        def deserialized_active_job_args
          active_job_args = ActiveJob::Arguments.deserialize(active_job_original_args)

          # ActiveJob 7 (aj7) changed deserialization structure, adding passed arguments
          # in an aj-specific hash under the :args key
          aj7_args_hash = active_job_args.detect { |arg| arg.respond_to?(:key) && arg.key?(:args) }

          return active_job_args if aj7_args_hash.nil?

          active_job_args.delete(aj7_args_hash)
          active_job_args.concat(aj7_args_hash[:args])
        end

        def active_job_original_args
          active_job_args = job["args"].detect { |arg| arg.is_a?(Hash) && arg.key?("arguments") }
          active_job_args ||= {}
          active_job_args["arguments"] || []
        end
      end

      class EnqueuedJob
        extend Forwardable
        attr_reader :job
        delegate :[] => :@job

        def initialize(job)
          @job = job
        end

        def jid
          job["jid"]
        end

        def args
          @args ||= JobArguments.new(job).unwrapped_arguments
        end

        def context
          @context ||= job.except("args")
        end

        def ==(other)
          super(other) unless other.is_a?(EnqueuedJob)

          jid == other.jid
        end
        alias_method :eql?, :==
      end

      class EnqueuedJobs
        include Enumerable
        attr_reader :jobs

        def initialize(klass)
          @jobs = unwrap_jobs(klass.jobs).map { |job| EnqueuedJob.new(job) }
        end

        def includes?(arguments, options, count)
          matching = jobs.filter { |job| matches?(job, arguments, options) }

          case count[0]
          when :exactly
            matching.size == count[1]
          when :at_least
            matching.size >= count[1]
          when :at_most
            matching.size <= count[1]
          else
            matching.size > 0
          end
        end

        def each(&block)
          jobs.each(&block)
        end

        def minus!(other)
          self unless other.is_a?(EnqueuedJobs)

          @jobs -= other.jobs

          self
        end

        private

        def matches?(job, arguments, options)
          arguments_matches?(job, arguments) &&
            options_matches?(job, options)
        end

        def arguments_matches?(job, arguments)
          job_arguments = JobArguments.new(job)

          job_arguments.matches?(arguments)
        end

        def options_matches?(job, options)
          parser = JobOptionParser.new(job)

          parser.matches?(options)
        end

        def unwrap_jobs(jobs)
          return jobs if jobs.is_a?(Array)
          jobs.values.flatten
        end
      end

      # @api private
      class Base
        include RSpec::Mocks::ArgumentMatchers
        include RSpec::Matchers::Composable

        attr_reader :expected_arguments, :expected_options, :klass, :actual_jobs, :expected_count

        def initialize
          @expected_arguments = [any_args]
          @expected_options = {}
          set_expected_count :positive, 1
        end

        def with(*expected_arguments)
          @expected_arguments = normalize_arguments(expected_arguments)
          self
        end

        def at(timestamp)
          @expected_options["at"] = timestamp.to_time.to_i
          self
        end

        def in(interval)
          @expected_options["at"] = (Time.now.to_f + interval.to_f).to_i
          self
        end

        def immediately
          @expected_options["at"] = nil
          self
        end

        def on(queue)
          @expected_options["queue"] = queue
          self
        end

        def once
          set_expected_count :exactly, 1
          self
        end

        def twice
          set_expected_count :exactly, 2
          self
        end

        def thrice
          set_expected_count :exactly, 3
          self
        end

        def exactly(n)
          set_expected_count :exactly, n
          self
        end

        def at_least(n)
          set_expected_count :at_least, n
          self
        end

        def at_most(n)
          set_expected_count :at_most, n
          self
        end

        def times
          self
        end
        alias :time :times

        def set_expected_count(relativity, n)
          n =
            case n
            when Integer then n
            when :once   then 1
            when :twice  then 2
            when :thrice then 3
            else raise ArgumentError, "Unsupported #{n} in '#{relativity} #{n}'. Use either an Integer, :once, :twice, or :thrice."
            end
          @expected_count = [relativity, n]
        end

        def description
          "#{common_message} with arguments #{expected_arguments}"
        end

        def failure_message
          message = ["expected to #{common_message}"]
          if expected_arguments
            message << "  with arguments:"
            message << "    -#{formatted(expected_arguments)}"
          end

          if expected_options.any?
            message << "  with context:"
            message << "    -#{formatted(expected_options)}"
          end

          if actual_jobs.any?
            message << "but enqueued only jobs"
            if expected_arguments
              job_messages = actual_jobs.map do |job|
                base = ["  -JID:#{job.jid} with arguments:"]
                base << "    -#{formatted(job.args)}"
                if expected_options.any?
                  base << "   with context: #{formatted(job.context)}"
                end

                base.join("\n")
              end

              message << job_messages.join("\n")
            end
          else
            message << "but enqueued 0 jobs"
          end

          message.join("\n")
        end

        def common_message
          "#{prefix_message} #{count_message} #{klass} #{expected_count.last == 1 ? "job" : "jobs"}"
        end

        def prefix_message
          raise NotImplementedError
        end

        def count_message
          case expected_count[0]
          when :positive
            "a"
          when :exactly
            expected_count[1]
          else
            "#{expected_count[0].to_s.gsub('_', ' ')} #{expected_count[1]}"
          end
        end

        def failure_message_when_negated
          message = ["expected not to #{common_message} but enqueued #{actual_jobs.count}"]
          message << "  arguments: #{expected_arguments}" if expected_arguments.any?
          message << "  options: #{expected_options}" if expected_options.any?
          message.join("\n")
        end

        def formatted(thing)
          RSpec::Support::ObjectFormatter.format(thing)
        end

        def normalize_arguments(args)
          if args.is_a?(Array)
            args.map{ |x| normalize_arguments(x) }
          elsif args.is_a?(Hash)
            args.each_with_object({}) do |(key, value), hash|
              hash[key.to_s] = normalize_arguments(value)
            end
          elsif args.is_a?(Symbol)
            args.to_s
          else
            args
          end
        end
      end
    end
  end
end
