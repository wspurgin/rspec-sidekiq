module RSpec
  module Sidekiq
    module Matchers
      def be_processed_in expected
        BeProcessedIn.new expected
      end

      class BeProcessedIn
        def initialize expected
          @expected = expected
        end

        def description
          "be processed in the \"#{@expected}\" queue"
        end

        def failure_message
          "expected #{@klass} to be processed in the \"#{@expected}\" queue but got \"#{@actual}\""
        end

        def matches? job
          @klass = job.kind_of?(Class) ? job : job.class
          @actual = @klass.get_sidekiq_options["queue"]
          @actual.to_s == @expected.to_s
        end

        def negative_failure_message
          "expected #{@klass} to not be processed in the \"#{@expected}\" queue"
        end
      end
    end
  end
end