# frozen_string_literal: true

module RSpec
  module Sidekiq
    module Matchers
      def have_job_option(key, value)
        HaveJobOption.new(key, value)
      end

      def have_job_options(options)
        HaveJobOptions.new(options)
      end

      module JobOptionNormalization
        private

        def normalize_key(key)
          key.to_s
        end

        def normalize_value(value)
          case value
          when Hash
            value.each_with_object({}) do |(key, option_value), hash|
              hash[normalize_key(key)] = normalize_value(option_value)
            end
          when Array
            value.map { |item| normalize_value(item) }
          when Symbol
            value.to_s
          else
            value
          end
        end

        def formatted(value)
          RSpec::Support::ObjectFormatter.format(value)
        end
      end

      class HaveJobOption
        include JobOptionNormalization

        def initialize(key, value)
          @expected_key = normalize_key(key)
          @expected_value = normalize_value(value)
        end

        def description
          "have sidekiq option #{@expected_key}: #{formatted(@expected_value)}"
        end

        def matches?(job)
          @klass = job.is_a?(Class) ? job : job.class
          @options = @klass.get_sidekiq_options
          @actual_present = @options.key?(@expected_key)
          @actual_value = @options[@expected_key]
          @actual_present && RSpec::Support::FuzzyMatcher.values_match?(@expected_value, @actual_value)
        end

        def failure_message
          if !@actual_present
            "expected #{@klass} to have sidekiq option #{@expected_key} but it was not set"
          else
            "expected #{@klass} to have sidekiq option #{@expected_key}: #{formatted(@expected_value)} but got #{formatted(@actual_value)}"
          end
        end

        def failure_message_when_negated
          "expected #{@klass} to not have sidekiq option #{@expected_key}: #{formatted(@expected_value)}"
        end
      end

      class HaveJobOptions
        include JobOptionNormalization

        def initialize(options)
          @expected_options = normalize_value(options)
        end

        def description
          "have sidekiq options #{formatted(@expected_options)}"
        end

        def matches?(job)
          @klass = job.is_a?(Class) ? job : job.class
          @options = @klass.get_sidekiq_options
          @missing_keys = []
          @mismatched = {}

          @expected_options.each do |key, value|
            unless @options.key?(key)
              @missing_keys << key
              next
            end

            actual_value = @options[key]
            next if RSpec::Support::FuzzyMatcher.values_match?(value, actual_value)

            @mismatched[key] = actual_value
          end

          @missing_keys.empty? && @mismatched.empty?
        end

        def failure_message
          parts = ["expected #{@klass} to have sidekiq options #{formatted(@expected_options)}"]
          parts << "missing #{formatted(@missing_keys)}" if @missing_keys.any?
          parts << "mismatched #{formatted(@mismatched)}" if @mismatched.any?
          parts.join(" but ")
        end

        def failure_message_when_negated
          "expected #{@klass} to not have sidekiq options #{formatted(@expected_options)}"
        end
      end
    end
  end
end
