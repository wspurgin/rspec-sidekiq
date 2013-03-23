module RSpec
  module Sidekiq
    module Matchers
      def have_enqueued_jobs expected
        HaveEnqueuedJobs.new expected
      end

      class HaveEnqueuedJobs
        def initialize expected
          @expected = expected
        end

        def description
          "enqueues a #{@klass} job"
        end

        def failure_message
          "expected #{@klass} to have #{@expected} enqueued jobs but got #{@actual}"
        end

        def matches? klass
          @klass = klass
          @actual = klass.jobs.size
          @actual == @expected
        end
        
        def negative_failure_message
          "expected #{@klass} to not have #{@expected} enqueued jobs"
        end
      end
    end
  end
end