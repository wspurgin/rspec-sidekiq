# frozen_string_literal: true

require "rspec/core"
require "securerandom"
require "sidekiq/api"

require_relative "named_queues/job_store"
require_relative "named_queues/null_scheduled_set"
require_relative "named_queues/null_retry_set"
require_relative "named_queues/null_dead_set"

module RSpec
  module Sidekiq
    module NamedQueues
      class << self
        attr_accessor :job_store
      end

      module Client
        private

        def raw_push(payloads)
          result = super
          store = NamedQueues.job_store
          payloads.each { |payload| store.push(payload) } if store
          result
        end
      end
    end
  end
end

Sidekiq::Client.prepend(RSpec::Sidekiq::NamedQueues::Client)

RSpec.configure do |config|
  config.before(:each) do |example|
    next unless example.metadata[:stub_named_queues] == true

    store = RSpec::Sidekiq::NamedQueues::JobStore.new
    RSpec::Sidekiq::NamedQueues.job_store = store

    if Sidekiq::Client.respond_to?(:stubs)
      Sidekiq::ScheduledSet.stubs(:new) { RSpec::Sidekiq::NamedQueues::NullScheduledSet.new(store) }
      Sidekiq::RetrySet.stubs(:new) { RSpec::Sidekiq::NamedQueues::NullRetrySet.new(store) }
      Sidekiq::DeadSet.stubs(:new) { RSpec::Sidekiq::NamedQueues::NullDeadSet.new(store) }
    else
      allow(Sidekiq::ScheduledSet).to receive(:new) { RSpec::Sidekiq::NamedQueues::NullScheduledSet.new(store) }
      allow(Sidekiq::RetrySet).to receive(:new) { RSpec::Sidekiq::NamedQueues::NullRetrySet.new(store) }
      allow(Sidekiq::DeadSet).to receive(:new) { RSpec::Sidekiq::NamedQueues::NullDeadSet.new(store) }
    end
  end

  config.after(:each) do |example|
    next unless example.metadata[:stub_named_queues] == true

    RSpec::Sidekiq::NamedQueues.job_store = nil
  end
end
