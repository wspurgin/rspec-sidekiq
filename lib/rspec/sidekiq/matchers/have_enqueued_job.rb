module RSpec
  module Sidekiq
    module Matchers
      def have_enqueued_job *expected_arguments
        HaveEnqueuedJob.new expected_arguments
      end

      class HaveEnqueuedJob
        attr_reader :matchers

        def initialize expected_arguments
          @matchers = [ArgumentsMatcher.new(expected_arguments)]
        end

        def description
          @matchers.map(&:description).join(" and ") + "\n\n"
        end

        def failure_message
          @matchers.map(&:failure_message).join(" and ")
        end

        def negative_failure_message
          @matchers.map(&:negative_failure_message).join(" and ")
        end

        def to_be_performed_at(interval)
          @matchers << TimeMatcher.new(interval)
          self
        end
        alias :to_be_performed_in :to_be_performed_at

        def matches? klass
          @matchers.all?{ |matcher| matcher.matches?(klass) }
        end

        protected

        class TimeMatcher
          def initialize(interval)
            @interval = interval.utc
          end

          def matches?(klass)
            @klass = klass
            if ::Sidekiq::Testing.disabled?
              @actual = ::Sidekiq::ScheduledSet.new.map{|job| job.at}.compact
            else
              @actual = @klass.jobs.map { |job| Time.at(job['at']).utc }
            end
            @actual.any?{ |at| @interval.to_i == at.to_i }
          end

          def description
            "to be performed at #{@interval}"
          end

          def failure_message
            "to be performed in #{@interval} found times to be performed at #{@actual}"
          end

          def negative_failure_message
            "expected the job to no be performed in #{@interval}"
          end
        end

        class ArgumentsMatcher
          def initialize(expected_arguments)
            @expected_arguments = expected_arguments
          end

          def description
            "have an enqueued #{@klass} job with arguments #{@expected_arguments}"
          end

          def failure_message
            "expected to have an enqueued #{@klass} job with arguments #{@expected_arguments}, found: #{@actual}"
          end

          def negative_failure_message
            "expected to not have an enqueued #{@klass} job with arguments #{@expected_arguments}"
          end

          def matches?(klass)
            @klass = klass

            if ::Sidekiq::Testing.disabled?
              @actual = ::Sidekiq::Queue.new(@klass.get_sidekiq_options['queue']).map { |job| job.args }
            else
              @actual = @klass.jobs.map { |job| job['args'] }
            end
            @actual.any? {|arguments| Array(@expected_arguments) == arguments }
          end
        end
        alias_method :failure_message_when_negated, :negative_failure_message
      end
    end
  end
end
