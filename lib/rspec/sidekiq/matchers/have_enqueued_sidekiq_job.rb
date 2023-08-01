module RSpec
  module Sidekiq
    module Matchers
      def have_enqueued_sidekiq_job(*expected_arguments)
        HaveEnqueuedSidekiqJob.new expected_arguments
      end

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
          return false if job["at"].to_s.empty?
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

      class JobArguments
        def initialize(job)
          self.job = job
        end
        attr_accessor :job

        def matches?(expected_args)
          RSpec::Matchers::BuiltIn::ContainExactly.new(expected_args).matches?(unwrapped_arguments)
        end

        def unwrapped_arguments
          args = job['args']

          return deserialized_active_job_args if active_job?

          args
        end

        private

        def active_job?
          job["class"] == "ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper"
        end

        def deserialized_active_job_args
          _deserialized_active_job_args = ActiveJob::Arguments.deserialize(active_job_original_args)

          # ActiveJob 7 (aj7) changed deserialization structure, adding passed arguments
          # in an aj-specific hash under the :args key
          aj7_args_hash = _deserialized_active_job_args.detect { |arg| arg.respond_to?(:key) && arg.key?(:args) }

          return _deserialized_active_job_args if aj7_args_hash.nil?

          _deserialized_active_job_args.delete(aj7_args_hash)
          _deserialized_active_job_args.concat(aj7_args_hash[:args])
        end

        def active_job_original_args
          _active_job_args = job["args"].detect { |arg| arg.is_a?(Hash) && arg.key?("arguments") }
          _active_job_args ||= {}
          _active_job_args["arguments"] || []
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
      end

      class EnqueuedJobs
        attr_reader :jobs

        def initialize(klass)
          @jobs = unwrap_jobs(klass.jobs).map { |job| EnqueuedJob.new(job) }
        end

        def includes?(arguments, options)
          !!jobs.find { |job| matches?(job, arguments, options) }
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

      class HaveEnqueuedSidekiqJob
        attr_reader :klass, :expected_arguments, :expected_options, :actual_jobs

        def initialize(expected_arguments)
          @expected_arguments = expected_arguments
          @expected_options = {}
        end

        def matches?(klass)
          @klass = klass

          enqueued_jobs = EnqueuedJobs.new(klass)
          @actual_jobs = enqueued_jobs.jobs

          enqueued_jobs.includes?(jsonified_expected_arguments, expected_options)
        end

        def at(timestamp)
          @expected_options["at"] = timestamp.to_time.to_i
          self
        end

        def in(interval)
          @expected_options["at"] = (Time.now.to_f + interval.to_f).to_i
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
          message << "  with arguments:" if expected_arguments
          message << "    -#{expected_arguments.inspect}" if expected_arguments
          message << "  with context:" if expected_options.any?
          message << "    -#{expected_options}" if expected_options.any?
          message << "but have enqueued only jobs"
          if expected_arguments
            job_messages = actual_jobs.map do |job|
              base = "  -JID:#{job.jid} with arguments:"
              base << "\n    -#{job.args}"
              if expected_options.any?
                base << "\n   with context: #{job.context.inspect}"
              end

              base
            end

            message << job_messages.join("\n")
          end

          message.join("\n")
        end

        def failure_message_when_negated
          message = ["expected not to have an enqueued #{klass} job"]
          message << "  arguments: #{expected_arguments}" if expected_arguments.any?
          message << "  options: #{expected_options}" if expected_options.any?
          message.join("\n")
        end

        def jsonified_expected_arguments
          # We would just cast-to-parse-json, but we need to support
          # RSpec matcher args like #kind_of
          @jsonified_expected_arguments ||= begin
            expected_arguments.map do |arg|
              case arg.class
              when Symbol then arg.to_s
              when Hash then JSON.parse(arg.to_json)
              else
                arg
              end
            end
          end
        end
      end
    end
  end
end
