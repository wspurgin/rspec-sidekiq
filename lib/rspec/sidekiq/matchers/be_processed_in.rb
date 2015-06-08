module RSpec
  module Sidekiq
    module Matchers
      def be_processed_in(expected_queue)
        BeProcessedIn.new expected_queue
      end

      class BeProcessedIn
        def initialize(expected_queue)
          @expected_queue = expected_queue
        end

        def description
          "be processed in the \"#{@expected_queue}\" queue"
        end

        def failure_message
          "expected #{@klass} to be processed in the \"#{@expected_queue}\" queue but got \"#{@actual}\""
        end

        def matches?(job)
          @klass = job.is_a?(Class) ? job : job.class
          if @klass.methods.include?(:get_sidekiq_options)
            @actual = @klass.get_sidekiq_options['queue']
          else
            @actual = job.try(:queue_name)
          end
          @actual.to_s == @expected_queue.to_s
        end

        def failure_message_when_negated
          "expected #{@klass} to not be processed in the \"#{@expected_queue}\" queue"
        end
      end
    end
  end
end
