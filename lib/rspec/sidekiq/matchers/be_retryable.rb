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
          "retry #{number_of_description} times"
        end

        def failure_message
          "expected #{@klass} to retry #{number_of_description} times but got #{@actual}"
        end

        def matches? job
          @klass = job.class
          @actual = @klass.get_sidekiq_options["retry"]
          @actual == @expected
        end
        
        def negative_failure_message
          "expected #{@klass} to not retry #{number_of_description} times"
        end

        def number_of_description
          @expected.is_a?(Fixnum) ? @expected : "the default number of"
        end
      end
    end
  end
end