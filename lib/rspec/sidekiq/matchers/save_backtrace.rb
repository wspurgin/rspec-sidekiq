module RSpec
  module Sidekiq
    module Matchers
      def save_backtrace(expected_backtrace=true)
        SaveBacktrace.new expected_backtrace
      end

      class SaveBacktrace
        def initialize(expected_backtrace=true)
          @expected_backtrace = expected_backtrace
        end

        def description
          if @expected_backtrace.is_a?(Numeric)
            "save #{@expected_backtrace} lines of error backtrace" # backtrace: 5
          elsif @expected_backtrace
            'save error backtrace' # backtrace: true
          else
            'not save error backtrace' # backtrace: false
          end
        end

        def failure_message
          "expected #{@klass} to #{description} but got #{@actual}"
        end

        def matches?(job)
          @klass = job.is_a?(Class) ? job : job.class
          @actual = @klass.get_sidekiq_options['backtrace']
          @actual == @expected_backtrace
        end

        def failure_message_when_negated
          "expected #{@klass} to not #{description}".gsub 'not not ', ''
        end
      end
    end
  end
end
