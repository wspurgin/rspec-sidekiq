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
          "have #{@expected} enqueued #{@klass} job#{jobs_description}"
        end

        def failure_message
          "expected #{@klass} to have #{@expected} enqueued job#{jobs_description} but got #{@actual}"
        end

        def jobs_description
          "s" unless @expected == 1
        end

        def matches? klass
          @klass = klass
          @actual = klass.jobs.size
          @actual == @expected
        end
        
        def negative_failure_message
          "expected #{@klass} to not have #{@expected} enqueued job#{jobs_description}"
        end
      end
    end
  end
end