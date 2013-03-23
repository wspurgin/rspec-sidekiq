module RSpec
  module Sidekiq
    class << self
      def configure &block
        yield configuration

        configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end
    end
  end
end