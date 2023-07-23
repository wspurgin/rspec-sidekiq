require "rubygems"

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
      end

      def sidekiq_gte_7?
        Gem::Version.new(::Sidekiq::VERSION) >= Gem::Version.new("7.0.0")
      end
    end
  end
end
