module RSpec
  module Sidekiq
    module Matchers
      def be_deadable(expected_dead)
        BeDeadable.new expected_dead
      end

      class BeDeadable
        def initialize(expected_dead)
          @expected_dead = expected_dead
        end

        def message_for(expected_dead)
          expected_dead ? 'dead' : 'not dead'
        end

        def description
          "be #{message_for(@expected_dead)} in queue"
        end

        def failure_message
          "expected #{@klass} to be \"#{message_for(@expected_dead)}\" but got \"#{message_for(@actual)}\""
        end

        def matches?(job)
          @klass = job.is_a?(Class) ? job : job.class
          @actual = @klass.get_sidekiq_options['dead']
          @actual == @expected_dead
        end

        def failure_message_when_negated
          "expected #{@klass} to be \"#{message_for(!@expected_dead)}\" but it does"
        end
      end
    end
  end
end