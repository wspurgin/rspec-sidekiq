module RSpec
  module Sidekiq
    module Matchers
      def have_enqueued_sidekiq_job(*expected_arguments)
        HaveEnqueuedSidekiqJob.new expected_arguments
      end

      # @api private
      class HaveEnqueuedSidekiqJob < Base
        DEPRECATION = [
          "[DEPRECATION] `have_enqueued_sidekiq_job()` is deprecated.",
          "Please use either `have_enqueued_sidekiq_job(no_args)` or `have_enqueued_sidekiq_job(any_args)`."
        ].join(" ")

        def initialize(expected_arguments)
          super()
          @expected_arguments = normalize_arguments(expected_arguments)
        end

        def matches?(job_class)
          @klass = job_class

          @actual_jobs = EnqueuedJobs.new(klass)

          warn DEPRECATION if expected_arguments == []
          actual_jobs.includes?(expected_arguments, expected_options)
        end
      end
    end
  end
end
