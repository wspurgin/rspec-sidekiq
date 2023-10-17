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
          job["class"] == "ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper"
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

        def includes?(arguments, options)
          !!jobs.find { |job| matches?(job, arguments, options) }
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

        attr_reader :expected_arguments, :expected_options, :klass, :actual_jobs

        def initialize
          @expected_arguments = [any_args]
          @expected_options = {}
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

        def description
          "have an enqueued #{klass} job with arguments #{expected_arguments}"
        end

        def failure_message
          message = ["expected to have an enqueued #{klass} job"]
          if expected_arguments
            message << "  with arguments:"
            message << "    -#{formatted(expected_arguments)}"
          end

          if expected_options.any?
            message << "  with context:"
            message << "    -#{formatted(expected_options)}"
          end

          if actual_jobs.any?
            message << "but have enqueued only jobs"
            if expected_arguments
              job_messages = actual_jobs.map do |job|
                base = "  -JID:#{job.jid} with arguments:"
                base << "\n    -#{formatted(job.args)}"
                if expected_options.any?
                  base << "\n   with context: #{formatted(job.context)}"
                end

                base
              end

              message << job_messages.join("\n")
            end
          end

          message.join("\n")
        end

        def failure_message_when_negated
          message = ["expected not to have an enqueued #{klass} job"]
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
