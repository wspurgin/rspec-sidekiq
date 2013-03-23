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

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Worker.clear_all if RSpec::Sidekiq.configuration.clear_all_enqueued_jobs
  end
end