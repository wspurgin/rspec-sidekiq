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
          @actual = @klass.get_sidekiq_options[unique_key]
          valid_value?
        end

        def valid_value?
          if sidekiq_enterprise?
            @actual > 0
          elsif sidekiq_unique_jobs?
            [true, :all].include?(@actual)
          end
        end

        def unique_key
          if sidekiq_enterprise?
            'unique_for'
          elsif sidekiq_unique_jobs?
            'unique'
          else
            fail "No gem included for uniquing"
          end
        end

        def sidekiq_enterprise?
          defined? ::Sidekiq::Enterprise
        end

        def sidekiq_unique_jobs?
          defined? ::SidekiqUniqueJobs
        end

        def failure_message_when_negated
          "expected #{@klass} to not be unique in the queue"
        end
      end
    end
  end
end
