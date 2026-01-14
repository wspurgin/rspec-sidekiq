# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::Sidekiq::Matchers::HaveJobOption do
  let(:worker) { create_worker retry: 5, queue: 'critical', dead: false, backtrace: true }
  let(:subject) { described_class.new(:retry, 5) }
  let(:formatter) { RSpec::Support::ObjectFormatter }

  before(:each) do
    subject.matches? worker
  end

  describe 'expected usage' do
    it 'matches' do
      expect(worker).to have_job_option(:retry, 5)
      expect(worker).to have_job_option('queue', 'critical')
      expect(worker).to have_job_option(:dead, false)
    end
  end

  describe '#have_job_option' do
    it 'returns instance' do
      expect(have_job_option(:retry, 5)).to be_a RSpec::Sidekiq::Matchers::HaveJobOption
    end
  end

  describe '#description' do
    it 'returns description' do
      expect(subject.description).to eq "have sidekiq option retry: #{formatter.format(5)}"
    end
  end

  describe '#failure_message' do
    it 'returns message when value mismatches' do
      mismatch = described_class.new(:retry, 10)
      mismatch.matches? worker
      expect(mismatch.failure_message).to eq "expected #{worker} to have sidekiq option retry: #{formatter.format(10)} but got #{formatter.format(5)}"
    end

    it 'returns message when option is missing' do
      missing = described_class.new(:timeout, 30)
      missing.matches? worker
      expect(missing.failure_message).to eq "expected #{worker} to have sidekiq option timeout but it was not set"
    end
  end

  describe '#matches?' do
    it 'returns true when matches' do
      expect(subject.matches? worker).to be true
    end

    it 'returns false when mismatches' do
      mismatch = described_class.new(:retry, 10)
      expect(mismatch.matches? worker).to be false
    end
  end

  describe '#failure_message_when_negated' do
    it 'returns message' do
      expect(subject.failure_message_when_negated).to eq "expected #{worker} to not have sidekiq option retry: #{formatter.format(5)}"
    end
  end
end

RSpec.describe RSpec::Sidekiq::Matchers::HaveJobOptions do
  let(:worker) { create_worker retry: 5, queue: 'critical', backtrace: true }
  let(:subject) { described_class.new(retry: 5, queue: 'critical') }
  let(:formatter) { RSpec::Support::ObjectFormatter }

  before(:each) do
    subject.matches? worker
  end

  describe 'expected usage' do
    it 'matches' do
      expect(worker).to have_job_options(retry: 5, queue: 'critical', backtrace: true)
    end
  end

  describe '#have_job_options' do
    it 'returns instance' do
      expect(have_job_options(retry: 5)).to be_a RSpec::Sidekiq::Matchers::HaveJobOptions
    end
  end

  describe '#description' do
    it 'returns description' do
      expected = { 'retry' => 5, 'queue' => 'critical' }
      expect(subject.description).to eq "have sidekiq options #{formatter.format(expected)}"
    end
  end

  describe '#failure_message' do
    it 'returns message when options mismatch' do
      mismatch = described_class.new(retry: 10, queue: 'critical')
      mismatch.matches? worker
      expected = { 'retry' => 10, 'queue' => 'critical' }
      mismatched = { 'retry' => 5 }
      expect(mismatch.failure_message).to eq "expected #{worker} to have sidekiq options #{formatter.format(expected)} but mismatched #{formatter.format(mismatched)}"
    end

    it 'returns message when options are missing' do
      missing = described_class.new(retry: 5, timeout: 30)
      missing.matches? worker
      expected = { 'retry' => 5, 'timeout' => 30 }
      missing_keys = ['timeout']
      expect(missing.failure_message).to eq "expected #{worker} to have sidekiq options #{formatter.format(expected)} but missing #{formatter.format(missing_keys)}"
    end
  end

  describe '#matches?' do
    it 'returns true when matches' do
      expect(subject.matches? worker).to be true
    end

    it 'returns false when mismatches' do
      mismatch = described_class.new(retry: 10)
      expect(mismatch.matches? worker).to be false
    end
  end

  describe '#failure_message_when_negated' do
    it 'returns message' do
      expected = { 'retry' => 5, 'queue' => 'critical' }
      expect(subject.failure_message_when_negated).to eq "expected #{worker} to not have sidekiq options #{formatter.format(expected)}"
    end
  end
end
