module RSpec
  module Sidekiq
    class Configuration
      attr_accessor :clear_all_enqueued_jobs

      def initialize
        @clear_all_enqueued_jobs = true
      end
    end
  end
end