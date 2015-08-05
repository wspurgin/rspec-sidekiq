module RSpec
  module Sidekiq
    module Matchers
      def be_expired_in(expected_argument)
        BeExpiredIn.new(expected_argument)
      end

      class BeExpiredIn
        def initialize(expected_argument)
          @expected_argument = expected_argument
        end

        def description
          "to expire in #{@expected_argument}"
        end

        def failure_message
          "expected to expire in #{@expected_argument} but expired in #{@actual}"
        end

        def failure_message_when_negated
          "expected to not expire in #{@expected_argument}"
        end

        def matches?(job)
          @klass = job.is_a?(Class) ? job : job.class
          @actual = @klass.get_sidekiq_options['expires_in']
          @actual.to_s == @expected_argument.to_s
        end
      end
    end
  end
end