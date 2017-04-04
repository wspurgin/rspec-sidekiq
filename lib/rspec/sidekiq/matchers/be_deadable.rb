module RSpec
  module Sidekiq
    module Matchers
      def be_deadable
        BeDeadable.new(false)
      end

       def not_be_deadable
        BeDeadable.new(true)
      end

      class BeDeadable
        def initialize(expected_dead)
          @expected_dead = expected_dead
        end

        def current_state
          @expected_dead ? 'dead' : 'not dead'
        end

        def description
          "be #{current_state} in queue"
        end

        def failure_message
          "expected #{@klass} to be \"#{current_state}\" but got \"#{@actual}\""
        end

        def matches?(job)
          @klass = job.is_a?(Class) ? job : job.class
          @actual = @klass.get_sidekiq_options['dead']
          @actual == @expected_dead
        end

        def failure_message_when_negated
          "expected #{@klass} to be \"#{current_state}\" but it does"
        end
      end
    end
  end
end