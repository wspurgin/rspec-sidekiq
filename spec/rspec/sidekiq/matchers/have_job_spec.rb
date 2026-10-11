# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.describe 'have_job matcher' do
  let(:worker) { create_worker }

  def build_scheduled_set(*items)
    store = RSpec::Sidekiq::NamedQueues::JobStore.new
    items.each { |item| store.push(item.merge("at" => 1.hour.from_now.to_f)) }
    RSpec::Sidekiq::NamedQueues::NullScheduledSet.new(store)
  end

  def build_retry_set(*items)
    store = RSpec::Sidekiq::NamedQueues::JobStore.new
    items.each { |item| store.add_retry(item) }
    RSpec::Sidekiq::NamedQueues::NullRetrySet.new(store)
  end

  def build_dead_set(*items)
    store = RSpec::Sidekiq::NamedQueues::JobStore.new
    items.each { |item| store.add_dead(item) }
    RSpec::Sidekiq::NamedQueues::NullDeadSet.new(store)
  end

  it 'matches scheduled jobs with arguments' do
    set = build_scheduled_set({ "class" => worker.to_s, "args" => ["arg"] })

    expect(set).to have_job(worker).with('arg')
    expect(set).to have_job(worker).with(:arg)
  end

  it 'matches ActiveJob symbol arguments in scheduled jobs' do
    TestJob.perform_later(:foo)
    set = build_scheduled_set(Sidekiq::Worker.jobs.last)

    expect(set).to have_job(TestJob).with(:foo)
  end

  it 'matches any job when class is omitted' do
    set = build_scheduled_set({ "class" => worker.to_s, "args" => ["arg"] })

    expect(set).to have_job
  end

  it 'supports count chaining' do
    set = build_scheduled_set(
      { "class" => worker.to_s, "args" => ["arg"] },
      { "class" => worker.to_s, "args" => ["arg"] }
    )

    expect(set).to have_job(worker).with('arg').twice
  end

  it 'supports scanning filters' do
    set = build_scheduled_set({ "class" => worker.to_s, "args" => ["arg"] })

    expect(set).to have_job(worker).scanning("*#{worker}*")
  end

  it 'supports retry set chains' do
    set = build_retry_set({
      "class" => worker.to_s,
      "args" => ["arg"],
      "error_message" => "boom",
      "error_class" => "RuntimeError",
      "retry_count" => 2
    })

    expect(set)
      .to have_job(worker)
      .with('arg')
      .with_error('boom')
      .with_error_class(RuntimeError)
      .with_retry_count(2)
  end

  it 'supports dead set chains' do
    set = build_dead_set({
      "class" => worker.to_s,
      "args" => ["arg"],
      "failed_at" => Time.now.to_f
    })

    expect(set)
      .to have_job(worker)
      .with('arg')
      .died_within(60)
  end
end
