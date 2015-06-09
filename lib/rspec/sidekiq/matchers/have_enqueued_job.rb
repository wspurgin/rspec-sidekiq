module RSpec
  module Sidekiq
    module Matchers
      def have_enqueued_job(*expected_arguments)
        HaveEnqueuedJob.new expected_arguments
      end

      class HaveEnqueuedJob
        attr_reader :klass, :expected_arguments, :actual

        def initialize(expected_arguments)
          @expected_arguments = expected_arguments
        end

        def description
          "have an enqueued #{klass} job with arguments #{expected_arguments}"
        end

        def failure_message
          "expected to have an enqueued #{klass} job with arguments #{expected_arguments}\n\n" \
          "found: #{actual}"
        end

        def matches?(klass)
          @klass = klass
          @actual = unwrapped_job_arguments(klass.jobs)
          @actual.any? { |arguments| contain_exactly?(arguments) }
        end

        def failure_message_when_negated
          "expected to not have an enqueued #{klass} job with arguments #{expected_arguments}"
        end

        private

        def unwrapped_job_arguments(jobs)
          if jobs.is_a? Hash
            jobs.values.flatten.map do |job|
              map_arguments(job).flatten
            end
          else
            map_arguments(jobs)
          end
        end

        def map_arguments(job)
          args = job_arguments(job) || job
          if args.respond_to?(:any?) && args.any? { |e| e.is_a? Hash }
            args.map { |a| map_arguments(a) }
          else
            args
          end
        end

        def job_arguments(hash)
          hash['arguments'] || hash['args'] unless hash.is_a? Array
        end

        def contain_exactly?(arguments)
          exactly = RSpec::Matchers::BuiltIn::ContainExactly.new(expected_arguments)
          exactly.matches?(arguments)
        end
      end
    end
  end
end
