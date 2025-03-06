# frozen_string_literal: true

require 'pry'

require 'sidekiq'
require 'rspec-sidekiq'

require 'active_job'
require 'action_mailer'
require 'active_support/testing/time_helpers'

require_relative 'support/init'

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.include RSpec::Sidekiq::Spec::Support::Factories
  config.include ActiveSupport::Testing::TimeHelpers

  # Add a setting to store our Sidekiq Version and share that around the specs
  config.add_setting :sidekiq_gte_7
  config.add_setting :sidekiq_gte_5
  config.sidekiq_gte_5 = Gem::Dependency.new("sidekiq", ">= 5.0.0").matching_specs.any?
  config.sidekiq_gte_7 = Gem::Dependency.new("sidekiq", ">= 7.0.0").matching_specs.any?

  config.before(:suite) do
    require "sidekiq/rails" if config.sidekiq_gte_7
    ActiveJob::Base.queue_adapter = :sidekiq
    ActiveJob::Base.logger.level = :warn


    if config.sidekiq_gte_5 && !config.sidekiq_gte_7
      require "active_record"
      ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)
      Sidekiq::Extensions.enable_delay!
    end
  end
end
