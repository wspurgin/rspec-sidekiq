# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'named queues stubs', stub_named_queues: true do
  let(:worker) { create_worker }

  it 'keeps immediate jobs in the fake queue' do
    jid = nil
    expect { jid = worker.perform_async('arg') }.to enqueue_sidekiq_job(worker).with('arg')

    expect(worker).to have_enqueued_sidekiq_job('arg').once
    expect(worker.jobs.map { |job| job['jid'] }).to eq([jid])
    expect(Sidekiq::ScheduledSet.new).not_to have_job(worker)
  end

  it 'keeps delayed jobs in both the fake queue and ScheduledSet' do
    jid = worker.perform_in(60, 'arg')

    expect(worker).to have_enqueued_sidekiq_job('arg').once
    expect(worker.jobs.map { |job| job['jid'] }).to eq([jid])
    expect(Sidekiq::ScheduledSet.new).to have_job(worker).with('arg').once
    expect(Sidekiq::ScheduledSet.new.map { |entry| entry.item['jid'] }).to eq([jid])
  end

  it 'preserves jobs pushed through the client class' do
    jid = Sidekiq::Client.push('class' => worker, 'args' => ['arg'])

    expect(worker).to have_enqueued_sidekiq_job('arg').once
    expect(worker.jobs.map { |job| job['jid'] }).to eq([jid])
  end

  %w[class instance].each do |client_type|
    it "keeps bulk jobs in both queues through the client #{client_type}" do
      client = client_type == 'class' ? Sidekiq::Client : Sidekiq::Client.new
      jids = client.push_bulk('class' => worker, 'args' => [[1], [2]], 'at' => 1.hour.from_now.to_f)

      expect(worker).to have_enqueued_sidekiq_job(1).once
      expect(worker).to have_enqueued_sidekiq_job(2).once
      expect(worker.jobs.map { |job| job['jid'] }).to eq(jids)
      expect(Sidekiq::ScheduledSet.new).to have_job(worker).exactly(2).times
      expect(Sidekiq::ScheduledSet.new.map { |entry| entry.item['jid'] }).to eq(jids)
    end
  end

  it 'does not record jobs rejected by client middleware' do
    client = Sidekiq::Client.new
    allow(client.middleware).to receive(:invoke).and_return(nil)

    expect(client.push('class' => worker, 'args' => [], 'at' => 1.hour.from_now.to_f)).to be_nil
    expect(worker.jobs).to be_empty
    expect(Sidekiq::ScheduledSet.new).not_to have_job(worker)
  end

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

  describe 'have_job matcher integration' do
    it 'matches scheduled jobs' do
      worker.perform_at(1.hour.from_now, 'arg')

      expect(Sidekiq::ScheduledSet.new).to have_job(worker).with('arg')
    end

    it 'supports count matching on scheduled jobs' do
      2.times { worker.perform_at(1.hour.from_now, 'arg') }

      expect(Sidekiq::ScheduledSet.new).to have_job(worker).with('arg').twice
    end

    it 'supports scanning filters on scheduled jobs' do
      store = RSpec::Sidekiq::NamedQueues.job_store
      store.push("class" => worker.to_s, "args" => ["arg"], "at" => 1.hour.from_now.to_f)

      expect(Sidekiq::ScheduledSet.new).to have_job(worker).scanning("*#{worker}*")
    end

    it 'matches retry jobs with error details' do
      store = RSpec::Sidekiq::NamedQueues.job_store
      store.add_retry(
        "class" => worker.to_s,
        "args" => ["arg"],
        "error_message" => "boom",
        "error_class" => "RuntimeError",
        "retry_count" => 2
      )

      expect(Sidekiq::RetrySet.new)
        .to have_job(worker)
        .with('arg')
        .with_error('boom')
        .with_error_class(RuntimeError)
        .with_retry_count(2)
    end

    it 'matches dead jobs with died_within' do
      store = RSpec::Sidekiq::NamedQueues.job_store
      store.add_dead(
        "class" => worker.to_s,
        "args" => ["arg"],
        "failed_at" => Time.now.to_f
      )

      expect(Sidekiq::DeadSet.new)
        .to have_job(worker)
        .with('arg')
        .died_within(60)
    end
  end
end
