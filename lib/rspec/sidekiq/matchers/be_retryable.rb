module RSpec
  module Sidekiq
    module Matchers
      def be_retryable expected
        BeRetryable.new expected
      end

      class BeRetryable
        def initialize expected
          @expected = expected
        end

        def description
          if @expected.is_a?(Fixnum)
            "retry #{@expected} times"          # retry: 5
          elsif @expected
            "retry the default number of times" # retry: true
          else
            "not retry"                         # retry: false
          end
        end

        def failure_message
          "expected #{@klass} to #{description} but got #{@actual}"
        end

        def matches? job
          @klass = job.class
          @actual = @klass.get_sidekiq_options["retry"]
          @actual == @expected
        end
        
        def negative_failure_message
          "expected #{@klass} to not #{description}"
        end
      end
    end
  end
end