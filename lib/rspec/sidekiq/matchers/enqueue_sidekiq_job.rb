module RSpec
  module Sidekiq
    module Matchers
      def enqueue_sidekiq_job(worker_class)
        EnqueuedSidekiqJob.new(worker_class)
      end

      class EnqueuedSidekiqJob
        include RSpec::Matchers::Composable

        def initialize(worker_class)
          @worker_class = worker_class
        end

        def with(*expected_arguments, **kwargs)
          fail 'keyword arguments serialization is not supported by Sidekiq' unless kwargs.empty?

          @expected_arguments = expected_arguments
          self
        end

        def at(timestamp)
          fail 'setting expecations with both `at` and `in` is not supported' if @expected_in

          @expected_at = timestamp
          self
        end

        def in(interval)
          fail 'setting expecations with both `at` and `in` is not supported' if @expected_at

          @expected_in = interval
          self
        end

        def matches?(block)
          filter(enqueued_in_block(block)).one?
        end

        def does_not_match?(block)
          filter(enqueued_in_block(block)).none?
        end

        def failure_message
          message = ["expected to enqueue #{worker_class} job"]
          message << "  arguments: #{expected_arguments}" if expected_arguments
          message << "  in: #{expected_in.inspect}" if expected_in
          message << "  at: #{expected_at}" if expected_at
          message.join("\n")
        end

        def failure_message_when_negated
          message = ["expected not to enqueue #{worker_class} job"]
          message << "  arguments: #{expected_arguments}" if expected_arguments
          message << "  in: #{expected_in.inspect}" if expected_in
          message << "  at: #{expected_at}" if expected_at
          message.join("\n")
        end

        def supports_block_expectations?
          true
        end

        def supports_value_expectations?
          false
        end

        private

        def enqueued_in_block(block)
          before = @worker_class.jobs.dup
          block.call
          @worker_class.jobs - before
        end

        def filter(jobs)
          jobs = jobs.select { |job| timestamps_match_rounded_to_seconds?(job['at']) } if expected_at
          jobs = jobs.select { |job| intervals_match_rounded_to_seconds?(job['at']) } if expected_in
          jobs = jobs.select { |job| values_match?(expected_arguments, job['args']) } if expected_arguments
          jobs
        end

        # Due to zero nsec precision of `Time.now` (and therefore `5.minutes.from_now`) on
        # some platforms, and lossy Sidekiq serialization that uses `.to_f` on timestamps,
        # values won't match unless rounded.
        # Rounding to whole seconds is sub-optimal but simple.
        def timestamps_match_rounded_to_seconds?(actual)
          return false if actual.nil?

          actual_time = Time.at(actual)
          values_match?(expected_at, actual_time) ||
            expected_at.to_i == actual_time.to_i
        end

        def intervals_match_rounded_to_seconds?(actual)
          return false if actual.nil?

          actual_time = Time.at(actual)
          expected_in.from_now.to_i == actual_time.to_i
        end

        attr_reader :worker_class, :expected_arguments, :expected_at, :expected_in
      end
    end
  end
end
