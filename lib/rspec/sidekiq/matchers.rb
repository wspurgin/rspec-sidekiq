require "rspec/sidekiq/matchers/have_enqueued_jobs"

RSpec.configure do |config|
  config.include RSpec::Sidekiq::Matchers
end