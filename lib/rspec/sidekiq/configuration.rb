# frozen_string_literal: true

require "rubygems"
require "set"

module RSpec
  module Sidekiq
    class Configuration
      attr_accessor :clear_all_enqueued_jobs,
        :enable_terminal_colours,
        :warn_when_jobs_not_processed_by_sidekiq

      def initialize
        # Display settings defaults
        @enable_terminal_colours = true

        # Functional settings defaults
        @clear_all_enqueued_jobs = true
        @warn_when_jobs_not_processed_by_sidekiq = true
        @silence_warnings = Set.new
      end

      def sidekiq_gte_7?
        Gem::Version.new(::Sidekiq::VERSION) >= Gem::Version.new("7.0.0")
      end

      def sidekiq_gte_8?
        Gem::Version.new(::Sidekiq::VERSION) >= Gem::Version.new("8.0.0")
      end

      def silence_warning(symbol)
        @silence_warnings << symbol
      end

      def warn_for?(symbol)
        !@silence_warnings.include?(symbol)
      end
    end
  end
end
