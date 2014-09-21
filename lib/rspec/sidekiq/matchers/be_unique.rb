module RSpec
  module Sidekiq
    module Matchers
      def be_unique
        BeUnique.new
      end

      class BeUnique
        def description
          'be unique in the queue'
        end

        def failure_message
          "expected #{@klass} to be unique in the queue"
        end

        def matches?(job)
          @klass = job.is_a?(Class) ? job : job.class
          @actual = @klass.get_sidekiq_options['unique']
          [true, :all].include?(@actual)
        end

        def failure_message_when_negated
          "expected #{@klass} to not be unique in the queue"
        end
      end
    end
  end
end
