module RSpec
  module Sidekiq
    module Matchers
      def be_unique
        BeUnique.new
      end

      class BeUnique
        def description
          "be unique in the queue"
        end

        def failure_message
          "expected #{@klass} to be unique in the queue"
        end

        def matches? job
          @klass = job.kind_of?(Class) ? job : job.class
          @actual = @klass.get_sidekiq_options["unique"]
          @actual == true
        end

        def negative_failure_message
          "expected #{@klass} to not be unique in the queue"
        end
      end
    end
  end
end