# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'named queues stubs', stub_named_queues: true do
  let(:worker) { create_worker }

  it 'stores scheduled jobs for ScheduledSet' do
    worker.perform_at(1.hour.from_now, 'arg')

    classes = Sidekiq::ScheduledSet.new.map { |entry| entry.item["class"].to_s }
    expect(classes).to include(worker.to_s)
  end

  it 'exposes retry and dead sets from the job store' do
    store = RSpec::Sidekiq::NamedQueues.job_store

    store.add_retry(
      "class" => worker.to_s,
      "args" => ["arg"],
      "error_message" => "boom",
      "error_class" => "RuntimeError",
      "retry_count" => 1
    )

    store.add_dead(
      "class" => worker.to_s,
      "args" => ["arg"],
      "failed_at" => Time.now.to_f
    )

    retry_classes = Sidekiq::RetrySet.new.map { |entry| entry.item["class"] }
    dead_classes = Sidekiq::DeadSet.new.map { |entry| entry.item["class"] }

    expect(retry_classes).to include(worker.to_s)
    expect(dead_classes).to include(worker.to_s)
  end
end
