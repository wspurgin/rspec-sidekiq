require "sidekiq/testing"

require "rspec/sidekiq/configuration"
require "rspec/sidekiq/sidekiq"

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Worker.clear_all if RSpec::Sidekiq.configuration.clear_all_enqueued_jobs
  end
end