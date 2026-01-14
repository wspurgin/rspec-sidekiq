# frozen_string_literal: true

require "rspec/core"
require "rspec/matchers"
require "rspec/mocks/argument_list_matcher"
require "rspec/mocks/argument_matchers"

require_relative "matchers/base"
require_relative "matchers/be_delayed"
require_relative "matchers/be_expired_in"
require_relative "matchers/be_processed_in"
require_relative "matchers/be_retryable"
require_relative "matchers/be_unique"
require_relative "matchers/have_job"
require_relative "matchers/have_enqueued_sidekiq_job"
require_relative "matchers/have_job_options"
require_relative "matchers/save_backtrace"
require_relative "matchers/enqueue_sidekiq_job"

RSpec.configure do |config|
  config.include RSpec::Sidekiq::Matchers
end
