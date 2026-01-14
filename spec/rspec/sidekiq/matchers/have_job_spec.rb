# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.describe 'have_job matcher' do
  FakeEntry = Struct.new(:item) do
    def klass
      item["class"]
    end

    def wrapped
      item["wrapped"]
    end

    def args
      item["args"]
    end

    def error_message
      item["error_message"]
    end

    def error_class
      item["error_class"]
    end

    def retry_count
      item["retry_count"]
    end

    def failed_at
      item["failed_at"]
    end
  end

  class FakeSet
    include Enumerable

    def initialize(entries)
      @entries = entries
    end

    def each
      return enum_for(:each) unless block_given?

      @entries.each { |entry| yield entry }
    end

    def scan(pattern)
      return enum_for(:scan, pattern) unless block_given?

      @entries.select { |entry| File.fnmatch?(pattern, entry.item.to_json) }
        .each { |entry| yield entry }
    end
  end

  let(:worker) { create_worker }

  it 'matches scheduled jobs with arguments' do
    entry = FakeEntry.new({ "class" => worker.to_s, "args" => ["arg"] })
    set = FakeSet.new([entry])

    expect(set).to have_job(worker).with('arg')
  end

  it 'matches any job when class is omitted' do
    entry = FakeEntry.new({ "class" => worker.to_s, "args" => ["arg"] })
    set = FakeSet.new([entry])

    expect(set).to have_job
  end

  it 'supports count chaining' do
    entries = Array.new(2) { FakeEntry.new({ "class" => worker.to_s, "args" => ["arg"] }) }
    set = FakeSet.new(entries)

    expect(set).to have_job(worker).with('arg').twice
  end

  it 'supports scanning filters' do
    entry = FakeEntry.new({ "class" => worker.to_s, "args" => ["arg"] })
    set = FakeSet.new([entry])

    expect(set).to have_job(worker).scanning("*#{worker}*")
  end

  it 'supports retry set chains' do
    entry = FakeEntry.new({
      "class" => worker.to_s,
      "args" => ["arg"],
      "error_message" => "boom",
      "error_class" => "RuntimeError",
      "retry_count" => 2
    })
    set = FakeSet.new([entry])

    expect(set)
      .to have_job(worker)
      .with('arg')
      .with_error('boom')
      .with_error_class(RuntimeError)
      .with_retry_count(2)
  end

  it 'supports dead set chains' do
    entry = FakeEntry.new({
      "class" => worker.to_s,
      "args" => ["arg"],
      "failed_at" => Time.now.to_f
    })
    set = FakeSet.new([entry])

    expect(set)
      .to have_job(worker)
      .with('arg')
      .died_within(60)
  end
end
