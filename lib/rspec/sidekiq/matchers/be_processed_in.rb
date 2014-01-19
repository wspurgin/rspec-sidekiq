module RSpec
  module Sidekiq
    module Matchers
      def be_processed_in expected_queue
        BeProcessedIn.new expected_queue
      end

      class BeProcessedIn
        def initialize expected_queue
          @expected_queue = expected_queue
        end

        def description
          "be processed in the \"#{@expected_queue}\" queue"
        end

        def failure_message
          "expected #{@klass} to be processed in the \"#{@expected_queue}\" queue but got \"#{@actual}\""
        end

        def matches? job
          @klass = job.kind_of?(Class) ? job : job.class
          @actual = @klass.get_sidekiq_options["queue"]
          @actual.to_s == @expected_queue.to_s
        end

        def negative_failure_message
          "expected #{@klass} to not be processed in the \"#{@expected_queue}\" queue"
        end
      end
    end
  end
end