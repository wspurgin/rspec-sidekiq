# frozen_string_literal: true

module RSpec
  module Sidekiq
    module Matchers
      def have_enqueued_sidekiq_job(*expected_arguments)
        HaveEnqueuedSidekiqJob.new expected_arguments
      end

      # @api private
      class HaveEnqueuedSidekiqJob < Base
        def initialize(expected_arguments)
          super()
          @expected_arguments = normalize_arguments(expected_arguments)
        end

        def matches?(job_class)
          @klass = job_class

          @actual_jobs = EnqueuedJobs.new(klass)

          actual_jobs.includes?(
            expected_arguments == [] ? any_args : expected_arguments,
            expected_options,
            expected_count
          )
        end

        def prefix_message
          "have enqueued"
        end
      end
    end
  end
end
