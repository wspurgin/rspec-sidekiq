require "rspec/core"
require "rspec/sidekiq/matchers/be_processed_in"
require "rspec/sidekiq/matchers/be_retryable"
require "rspec/sidekiq/matchers/have_enqueued_job"
require "rspec/sidekiq/matchers/have_enqueued_jobs"

if defined?(Sidekiq::Middleware::Client::UniqueJobs)
  require "rspec/sidekiq/matchers/be_unique"
end

RSpec.configure do |config|
  config.include RSpec::Sidekiq::Matchers
end
