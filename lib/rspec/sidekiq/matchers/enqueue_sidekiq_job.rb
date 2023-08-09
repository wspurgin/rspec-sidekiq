module RSpec
  module Sidekiq
    module Matchers
      # @api private
      class EnqueueSidekiqJob < Base
        attr_reader :original_jobs # Plus that from Base

        def initialize(job_class)
          super()
          @klass = job_class || ::Sidekiq::Job
        end

        def matches?(proc)
          raise ArgumentError, "Only block syntax supported for enqueue_sidekiq_job" unless Proc === proc

          @original_jobs = EnqueuedJobs.new(@klass)
          proc.call
          @actual_jobs = EnqueuedJobs.new(@klass).minus!(original_jobs)

          if @actual_jobs.none?
            return false
          end

          @actual_jobs.includes?(expected_arguments, expected_options)
        end

        def failure_message
          if @actual_jobs.none?
            "expected to enqueue a job but enqueued 0"
          else
            super
          end
        end

        def failure_message_when_negated
          messages = ["expected not to enqueue a #{@klass} job but enqueued #{actual_jobs.count}"]

          messages << "  with arguments #{formatted(expected_arguments)}" if expected_arguments
          messages << "  with context #{formatted(expected_options)}" if expected_options

          messages.join("\n")
        end

        def supports_block_expectations?
          true
        end
      end

      # @api public
      #
      # Passes if a Job is enqueued as the result of a block. Chainable `with`
      # for arguments, `on` for queue, `at` for queued for a specific time, and
      # `in` for a specific interval delay to being queued
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
      def enqueue_sidekiq_job(job_class = nil)
        EnqueueSidekiqJob.new(job_class)
      end
    end
  end
end
