module RSpec
  module Sidekiq
    module Matchers
      def be_retryable(expected_retry)
        BeRetryable.new expected_retry
      end

      class BeRetryable
        def initialize(expected_retry)
          @expected_retry = expected_retry
        end

        def description
          num_class = 1.class # Ruby 2.4 returns Integer, older returns Fixnum
          if @expected_retry.is_a?(num_class)
            "retry #{@expected_retry} times"    # retry: 5
          elsif @expected_retry
            'retry the default number of times' # retry: true
          else
            'not retry'                         # retry: false
          end
        end

        def failure_message
          "expected #{@klass} to #{description} but got #{@actual}"
        end

        def matches?(job)
          @klass = job.is_a?(Class) ? job : job.class
          @actual = @klass.get_sidekiq_options['retry']
          @actual == @expected_retry
        end

        def failure_message_when_negated
          "expected #{@klass} to not #{description}".gsub 'not not ', ''
        end
      end
    end
  end
end
