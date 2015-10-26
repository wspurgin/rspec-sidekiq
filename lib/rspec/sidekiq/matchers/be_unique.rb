module RSpec
  module Sidekiq
    module Matchers
      def be_unique
        BeUnique.new
      end

      class BeUnique
        def self.new
          if defined?(::Sidekiq::Enterprise)
            SidekiqEnterprise.new
          elsif defined?(::SidekiqUniqueJobs)
            SidekiqUniqueJobs.new
          else
            fail "No support found for Sidekiq unique jobs"
          end
        end

        class Base
          def description
            'be unique in the queue'
          end

          def failure_message
            if !interval_matches? && @expected_interval
              "expected #{@klass} to be unique for #{@expected_interval} seconds, "\
              "but its interval was #{actual_interval} seconds"
            else
              "expected #{@klass} to be unique in the queue"
            end
          end

          def matches?(job)
            @klass = job.is_a?(Class) ? job : job.class
            @actual = @klass.get_sidekiq_options[unique_key]
            !!(value_matches? && interval_matches?)
          end

          def for(interval)
            @expected_interval = interval
            self
          end

          def interval_specified?
            @expected_interval
          end

          def interval_matches?
            !interval_specified? || actual_interval == @expected_interval
          end

          def failure_message_when_negated
            "expected #{@klass} to not be unique in the queue"
          end
        end

        class SidekiqUniqueJobs < Base
          def actual_interval
            @klass.get_sidekiq_options['unique_job_expiration']
          end

          def value_matches?
            [true, :all].include?(@actual)
          end

          def unique_key
            'unique'
          end
        end

        class SidekiqEnterprise < Base
          def actual_interval
            @actual
          end

          def value_matches?
            @actual && @actual > 0
          end

          def unique_key
            'unique_for'
          end
        end
      end
    end
  end
end
