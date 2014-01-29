module RSpec
  module Sidekiq
    module Matchers
      def have_enqueued_job *expected_arguments
        HaveEnqueuedJob.new expected_arguments
      end

      class HaveEnqueuedJob
        def initialize expected_arguments
          @expected_arguments = expected_arguments
        end

        def description
          "have an enqueued #{@klass} job with arguments #{@expected_arguments}"
        end

        def failure_message
          "expected to have an enqueued #{@klass} job with arguments #{@expected_arguments}\n\n" +
            "found: #{@actual}"
        end

        def matches? klass
          @klass = klass

          if ::Sidekiq::Testing.disabled?
            @actual = ::Sidekiq::Queue.new(@klass.get_sidekiq_options['queue']).map(&:args)
          else
            @actual = @klass.jobs.map { |job| job["args"] }
          end
          @actual.any? {|arguments| Array(@expected_arguments) == arguments }
        end

        def negative_failure_message
          "expected to not have an enqueued #{@klass} job with arguments #{@expected_arguments}"
        end
      end
    end
  end
end
