module RSpec
  module Sidekiq
    module Matchers
      def have_enqueued_job *expected
        HaveEnqueuedJob.new expected
      end

      class HaveEnqueuedJob
        def initialize expected
          @expected = expected
        end

        def description
          "have an enqueued #{@klass} job with arguments #{@expected}"
        end

        def failure_message
          "expected to have an enqueued #{@klass} job with arguments #{@expected} but none found\n\n" +
          "found: #{@actual}"
        end

        def matches? klass
          @klass = klass
          @actual = klass.jobs.map { |job| job["args"] }
          @actual.include? @expected
        end
        
        def negative_failure_message
          "expected to not have an enqueued #{@klass} job with arguments #{@expected}"
        end
      end
    end
  end
end