module RSpec
  module Sidekiq
    module Matchers
      def have_enqueued_sidekiq_job(*expected_arguments)
        HaveEnqueuedSidekiqJob.new expected_arguments
      end

      # @api private
      class HaveEnqueuedSidekiqJob < Base
        DEPRECATION = [
          "[WARNING] `have_enqueued_sidekiq_job()` without arguments default behavior will change in next major release.",
          "Use `have_enqueued_sidekiq_job(no_args)` to maintain legacy behavior.",
          "More available here: https://github.com/wspurgin/rspec-sidekiq/wiki/have_enqueued_sidekiq_job-without-argument-default-behavior"
        ].join(" ").freeze

        def initialize(expected_arguments)
          super()

          if expected_arguments == [] && RSpec::Sidekiq.configuration.warn_for?(:have_enqueued_sidekiq_job_default)
            Kernel.warn(DEPRECATION, uplevel: 3)
          end
          @expected_arguments = normalize_arguments(expected_arguments)
        end

        def matches?(job_class)
          @klass = job_class

          @actual_jobs = EnqueuedJobs.new(klass)
          actual_jobs.includes?(expected_arguments, expected_options)
        end
      end
    end
  end
end
