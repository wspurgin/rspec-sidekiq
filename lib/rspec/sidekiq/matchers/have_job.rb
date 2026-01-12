# frozen_string_literal: true

module RSpec
  module Sidekiq
    module Matchers
      def have_job(expected_job_class = nil)
        HaveJob.new(expected_job_class)
      end

      # @api private
      class HaveJob
        include RSpec::Mocks::ArgumentMatchers

        attr_reader :expected_job_class, :expected_arguments, :expected_count

        def initialize(expected_job_class)
          @expected_job_class = expected_job_class
          @expected_arguments = [any_args]
          @expected_count = [:positive, 1]
          @scan_pattern = nil
          @expected_error_message = nil
          @expected_error_class = nil
          @expected_retry_count = nil
          @expected_died_within = nil
        end

        def with(*expected_arguments)
          @expected_arguments = normalize_arguments(expected_arguments)
          self
        end

        def scanning(pattern)
          @scan_pattern = pattern
          self
        end

        def with_error(message)
          @expected_error_message = message
          self
        end

        def with_error_class(error_class)
          @expected_error_class = error_class
          self
        end

        def with_retry_count(count)
          @expected_retry_count = count
          self
        end

        def died_within(duration)
          @expected_died_within = duration
          self
        end

        def never
          set_expected_count :exactly, 0
          self
        end

        def once
          set_expected_count :exactly, 1
          self
        end

        def twice
          set_expected_count :exactly, 2
          self
        end

        def thrice
          set_expected_count :exactly, 3
          self
        end

        def exactly(n)
          set_expected_count :exactly, n
          self
        end

        def at_least(n)
          set_expected_count :at_least, n
          self
        end

        def at_most(n)
          set_expected_count :at_most, n
          self
        end

        def times
          self
        end
        alias :time :times

        def matches?(set_or_class)
          @set_class = set_or_class.is_a?(Class) ? set_or_class : set_or_class.class
          set = set_or_class.is_a?(Class) ? set_or_class.new : set_or_class

          @actual_jobs = matching_jobs(set)

          count_matches?(@actual_jobs.size)
        end

        def description
          set_label = @set_class || "set"
          "have #{count_message} #{job_message} in #{set_label}"
        end

        def failure_message
          message = ["expected to #{description}"]
          if expected_arguments.any?
            message << "  with arguments:"
            message << "    -#{formatted(expected_arguments)}"
          end

          filters = []
          filters << "error: #{formatted(@expected_error_message)}" if @expected_error_message
          filters << "error_class: #{formatted(normalize_error_class(@expected_error_class))}" if @expected_error_class
          filters << "retry_count: #{formatted(@expected_retry_count)}" if @expected_retry_count
          if @expected_died_within
            filters << "died_within: #{formatted(@expected_died_within)}"
          end
          message << "  with filters: #{filters.join(', ')}" if filters.any?
          message << "but found #{@actual_jobs.size}"
          message.join("\n")
        end

        def failure_message_when_negated
          "expected not to #{description} but found #{@actual_jobs.size}"
        end

        private

        def matching_jobs(set)
          entries = enumerable_for(set)

          entries.each_with_object([]) do |entry, matches|
            job = NamedQueueJob.new(entry)
            next unless job_class_matches?(job)
            next unless arguments_match?(job)
            next unless error_matches?(job)
            next unless error_class_matches?(job)
            next unless retry_count_matches?(job)
            next unless died_within_matches?(job)

            matches << job
          end
        end

        def enumerable_for(set)
          return set unless @scan_pattern
          return set.scan(@scan_pattern) if set.respond_to?(:scan)

          set
        end

        def job_class_matches?(job)
          return true if expected_job_class.nil?

          expected_name = expected_job_class.to_s
          job.klass == expected_name || job.wrapped == expected_name
        end

        def arguments_match?(job)
          expected = expected_arguments == [] ? any_args : expected_arguments
          JobArguments.new(job.item).matches?(expected)
        end

        def error_matches?(job)
          return true if @expected_error_message.nil?

          RSpec::Support::FuzzyMatcher.values_match?(@expected_error_message, job.error_message)
        end

        def error_class_matches?(job)
          return true if @expected_error_class.nil?

          expected = normalize_error_class(@expected_error_class)
          RSpec::Support::FuzzyMatcher.values_match?(expected, job.error_class)
        end

        def retry_count_matches?(job)
          return true if @expected_retry_count.nil?

          RSpec::Support::FuzzyMatcher.values_match?(@expected_retry_count, job.retry_count)
        end

        def died_within_matches?(job)
          return true if @expected_died_within.nil?

          failed_at = job.failed_at
          return false if failed_at.nil?

          failed_at = failed_at.to_f
          cutoff = Time.now.to_f - @expected_died_within.to_f
          failed_at >= cutoff
        end

        def set_expected_count(relativity, n)
          n =
            case n
            when Integer then n
            when :once   then 1
            when :twice  then 2
            when :thrice then 3
            else raise ArgumentError, "Unsupported #{n} in '#{relativity} #{n}'. Use either an Integer, :once, :twice, or :thrice."
            end
          @expected_count = [relativity, n]
        end

        def count_matches?(actual)
          case expected_count[0]
          when :positive
            actual > 0
          when :exactly
            actual == expected_count[1]
          when :at_least
            actual >= expected_count[1]
          when :at_most
            actual <= expected_count[1]
          else
            false
          end
        end

        def count_message
          case expected_count[0]
          when :positive
            "a"
          when :exactly
            expected_count[1]
          else
            "#{expected_count[0].to_s.gsub('_', ' ')} #{expected_count[1]}"
          end
        end

        def job_message
          if expected_job_class
            if expected_count[0] == :positive && expected_count.last == 1
              expected_job_class.to_s
            else
              "#{expected_job_class} #{expected_count.last == 1 ? 'job' : 'jobs'}"
            end
          else
            expected_count.last == 1 ? "job" : "jobs"
          end
        end

        def normalize_arguments(args)
          if args.is_a?(Array)
            args.map { |x| normalize_arguments(x) }
          elsif args.is_a?(Hash)
            args.each_with_object({}) do |(key, value), hash|
              hash[key.to_s] = normalize_arguments(value)
            end
          elsif args.is_a?(Symbol)
            args.to_s
          else
            args
          end
        end

        def formatted(thing)
          RSpec::Support::ObjectFormatter.format(thing)
        end

        def normalize_error_class(error_class)
          return error_class.to_s if error_class.is_a?(Class) || error_class.is_a?(Module)

          error_class
        end
      end

      # @api private
      class NamedQueueJob
        attr_reader :entry, :item

        def initialize(entry)
          @entry = entry
          @item = entry.respond_to?(:item) ? entry.item : entry
        end

        def klass
          entry.respond_to?(:klass) ? entry.klass.to_s : item["class"].to_s
        end

        def wrapped
          item["wrapped"]
        end

        def args
          entry.respond_to?(:args) ? entry.args : item["args"]
        end

        def error_message
          entry.respond_to?(:error_message) ? entry.error_message : item["error_message"]
        end

        def error_class
          entry.respond_to?(:error_class) ? entry.error_class : item["error_class"]
        end

        def retry_count
          entry.respond_to?(:retry_count) ? entry.retry_count : item["retry_count"]
        end

        def failed_at
          entry.respond_to?(:failed_at) ? entry.failed_at : item["failed_at"]
        end
      end
    end
  end
end
