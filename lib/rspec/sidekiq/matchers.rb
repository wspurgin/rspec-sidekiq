# frozen_string_literal: true

require "rspec/core"
require "rspec/matchers"
require "rspec/mocks/argument_list_matcher"
require "rspec/mocks/argument_matchers"

require "rspec/sidekiq/matchers/base"
require "rspec/sidekiq/matchers/be_delayed"
require "rspec/sidekiq/matchers/be_expired_in"
require "rspec/sidekiq/matchers/be_processed_in"
require "rspec/sidekiq/matchers/be_retryable"
require "rspec/sidekiq/matchers/be_unique"
require "rspec/sidekiq/matchers/have_enqueued_sidekiq_job"
require "rspec/sidekiq/matchers/save_backtrace"
require "rspec/sidekiq/matchers/enqueue_sidekiq_job"

RSpec.configure do |config|
  config.include RSpec::Sidekiq::Matchers
end
