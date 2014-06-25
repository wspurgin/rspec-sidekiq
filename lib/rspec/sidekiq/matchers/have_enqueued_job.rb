module RSpec
  module Sidekiq
    module Matchers
      def have_enqueued_job *expected_arguments
        HaveEnqueuedJob.new expected_arguments
      end

      class HaveEnqueuedJob

        attr_reader :klass, :expected_arguments, :actual

        def initialize(expected_arguments)
          @expected_arguments = expected_arguments
        end

        def description
          "have an enqueued #{klass} job with arguments #{expected_arguments}"
        end

        def failure_message
          "expected to have an enqueued #{klass} job with arguments #{expected_arguments}\n\n" +
          "found: #{actual}"
        end

        def matches?(klass)
          @klass = klass
          @actual = klass.jobs.map { |job| job["args"] }
          @actual.any? { |arguments| contain_exactly?(arguments) }
        end

        def failure_message_when_negated
          "expected to not have an enqueued #{klass} job with arguments #{expected_arguments}"
        end

        private

        def contain_exactly?(arguments)
          exactly = RSpec::Matchers::BuiltIn::ContainExactly.new(expected_arguments)
          exactly.matches?(arguments)
        end

      end
    end
  end
end
