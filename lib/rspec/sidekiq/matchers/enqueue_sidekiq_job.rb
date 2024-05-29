# frozen_string_literal: true

module RSpec
  module Sidekiq
    module Matchers
      # @api private
      class EnqueueSidekiqJob < Base
        attr_reader :original_jobs # Plus that from Base

        def initialize(job_class)
          super()
          default = if RSpec::Sidekiq.configuration.sidekiq_gte_7?
            ::Sidekiq::Job
          else
            ::Sidekiq::Worker
          end

          @klass = job_class || default
        end

        def matches?(proc)
          raise ArgumentError, "Only block syntax supported for enqueue_sidekiq_job" unless Proc === proc

          @original_jobs = EnqueuedJobs.new(@klass)
          proc.call
          @actual_jobs = EnqueuedJobs.new(@klass).minus!(original_jobs)

          if @actual_jobs.none?
            return false
          end

          @actual_jobs.includes?(expected_arguments, expected_options, expected_count)
        end

        def prefix_message
          "enqueue"
        end

        def supports_block_expectations?
          true
        end
      end

      # @api public
      #
      # Passes if a Job is enqueued as the result of a block. Chainable `with`
      # for arguments, `on` for queue, `at` for queued for a specific time, and
      # `in` for a specific interval delay to being queued, `immediately` for
      # queued without delay.
      #
      # @example
      #
      #   expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job
      #
      #   # A specific job class
      #   expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job(AwesomeJob)
      #
      #   # with specific arguments
      #   expect { AwesomeJob.perform_async "Awesome!" }.to enqueue_sidekiq_job.with("Awesome!")
      #
      #   # On a specific queue
      #   expect { AwesomeJob.set(queue: "high").perform_async }.to enqueue_sidekiq_job.on("high")
      #
      #   # At a specific datetime
      #   specific_time = 1.hour.from_now
      #   expect { AwesomeJob.perform_at(specific_time) }.to enqueue_sidekiq_job.at(specific_time)
      #
      #   # In a specific interval (be mindful of freezing or managing time here)
      #   freeze_time do
      #     expect { AwesomeJob.perform_in(1.hour) }.to enqueue_sidekiq_job.in(1.hour)
      #   end
      #
      #   # Without any delay
      #   expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job.immediately
      #   expect { AwesomeJob.perform_at(1.hour.ago) }.to enqueue_sidekiq_job.immediately
      #
      #   ## Composable
      #
      #   expect do
      #     AwesomeJob.perform_async
      #     OtherJob.perform_async
      #   end.to enqueue_sidekiq_job(AwesomeJob).and enqueue_sidekiq_job(OtherJob)
      def enqueue_sidekiq_job(job_class = nil)
        EnqueueSidekiqJob.new(job_class)
      end
    end
  end
end
