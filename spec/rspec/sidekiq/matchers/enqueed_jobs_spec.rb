# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RSpec::Sidekiq::Matchers::EnqueuedJobs do
  let(:klass) { double('Worker') }

  describe '#minus!' do
    let(:job1) { { 'jid' => '1', 'args' => [1], 'class' => 'TestWorker' } }
    let(:job2) { { 'jid' => '2', 'args' => [2], 'class' => 'TestWorker' } }
    let(:job3) { { 'jid' => '3', 'args' => [3], 'class' => 'TestWorker' } }

    before do
      allow(klass).to receive(:jobs).and_return([job1, job2, job3])
    end

    it 'calculates the difference when given an EnqueuedJobs object' do
      described_class.new(klass)
      allow(klass).to receive(:jobs).and_return([job1, job2, job3])
      all_jobs = described_class.new(klass)
      allow(klass).to receive(:jobs).and_return([job1, job2])
      original = described_class.new(klass)
      result = all_jobs.minus!(original)

      expect(result).to be(all_jobs)
      expect(result.jobs.map(&:jid)).to eq([job3['jid']])
    end

    it 'returns self unchanged when given a non-EnqueuedJobs object' do
      jobs = described_class.new(klass)
      original_job_count = jobs.jobs.size
      result = jobs.minus!('not an EnqueuedJobs')

      expect(result).to be(jobs)
      expect(jobs.jobs.size).to eq(original_job_count)
    end

    it 'returns self unchanged when given nil' do
      jobs = described_class.new(klass)
      original_job_count = jobs.jobs.size

      result = jobs.minus!(nil)

      expect(result).to be(jobs)
      expect(jobs.jobs.size).to eq(original_job_count)
    end
  end
end
