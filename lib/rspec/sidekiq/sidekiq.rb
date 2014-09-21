module RSpec
  module Sidekiq
    class << self
      def configure(&block)
        yield configuration if block
      end

      def configuration
        @configuration ||= Configuration.new
      end
    end
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    message = '[rspec-sidekiq] WARNING! Sidekiq will *NOT* process jobs in this environment. See https://github.com/philostler/rspec-sidekiq/wiki/FAQ-&-Troubleshooting'
    message = "\e[33m#{message}\e[0m" if RSpec::Sidekiq.configuration.enable_terminal_colours
    puts message if RSpec::Sidekiq.configuration.warn_when_jobs_not_processed_by_sidekiq
  end

  config.before(:each) do
    Sidekiq::Worker.clear_all if RSpec::Sidekiq.configuration.clear_all_enqueued_jobs
  end
end
