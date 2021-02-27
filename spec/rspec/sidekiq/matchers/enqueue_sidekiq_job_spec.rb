require 'spec_helper'

RSpec.describe RSpec::Sidekiq::Matchers::EnqueuedSidekiqJob do
  let(:worker) do
    Class.new do
      include ::Sidekiq::Worker
    end
  end

  let(:another_worker) do
    Class.new do
      include ::Sidekiq::Worker
    end
  end

  it 'raises ArgumentError when used in value expectation' do
    expect {
      expect(worker.perform_async).to enqueue_sidekiq_job(worker)
    }.to raise_error
  end

  it 'fails when no worker class is specified' do
    expect {
      expect { worker.perform_async }.to enqueue_sidekiq_job
    }.to raise_error(ArgumentError)
  end

  it 'passes' do
    expect { worker.perform_async }
      .to enqueue_sidekiq_job(worker)
  end

  it 'fails when negated and job is enqueued' do
    expect {
      expect { worker.perform_async }.not_to enqueue_sidekiq_job(worker)
    }.to raise_error(/expected not to enqueue/)
  end

  context 'when no jobs were enqueued' do
    it 'fails' do
      expect {
        expect { } # nop
          .to enqueue_sidekiq_job(worker)
      }.to raise_error(/expected to enqueue/)
    end

    it 'passes with negation' do
      expect { } # nop
        .not_to enqueue_sidekiq_job(worker)
    end
  end

  context 'with another worker' do
    it 'fails' do
      expect {
        expect { worker.perform_async }
          .to enqueue_sidekiq_job(another_worker)
      }.to raise_error(/expected to enqueue/)
    end

    it 'passes with negation' do
      expect { worker.perform_async }
        .not_to enqueue_sidekiq_job(another_worker)
    end
  end

  it 'counts only jobs enqueued in block' do
    worker.perform_async
    expect { }.not_to enqueue_sidekiq_job(worker)
  end

  it 'counts jobs enqueued in block' do
    worker.perform_async
    expect { worker.perform_async }.to enqueue_sidekiq_job(worker)
  end

  it 'fails when too many jobs enqueued' do
    expect {
      expect {
        worker.perform_async
        worker.perform_async
      }.to enqueue_sidekiq_job(worker)
    }.to raise_error(/expected to enqueue/)
  end

  it 'fails when negated and several jobs enqueued' do
    expect {
      expect {
        worker.perform_async
        worker.perform_async
      }.not_to enqueue_sidekiq_job(worker)
    }.to raise_error(/expected not to enqueue/)
  end

  it 'passes with multiple jobs' do
    expect {
      another_worker.perform_async
      worker.perform_async
    }
      .to enqueue_sidekiq_job(worker)
      .and enqueue_sidekiq_job(another_worker)
  end

  context 'when enqueued with perform_at' do
    it 'passes' do
      future = 1.minute.from_now
      expect { worker.perform_at(future) }
        .to enqueue_sidekiq_job(worker).at(future)
    end

    it 'fails when timestamps do not match' do
      future = 1.minute.from_now
      expect {
        expect { worker.perform_at(future) }
          .to enqueue_sidekiq_job(worker).at(2.minutes.from_now)
      }.to raise_error(/expected to enqueue.+at:/m)
    end

    it 'matches timestamps with nanosecond precision' do
      100.times do
        future = 1.minute.from_now
        future = future.change(nsec: future.nsec.round(-3) + rand(999))
        expect { worker.perform_at(future) }
          .to enqueue_sidekiq_job(worker).at(future)
      end
    end

    it 'accepts composable matchers' do
      future = 1.minute.from_now
      slightly_earlier = 58.seconds.from_now
      expect { worker.perform_at(slightly_earlier) }
        .to enqueue_sidekiq_job(worker).at(a_value_within(5.seconds).of(future))
    end

    it 'fails when the job was enuqued for now' do
      expect {
        expect { worker.perform_async }
          .to enqueue_sidekiq_job(worker).at(1.minute.from_now)
      }.to raise_error(/expected to enqueue.+at:/m)
    end
  end

  context 'when enqueued with perform_in' do
    it 'passes' do
      interval = 1.minute
      expect { worker.perform_in(interval) }
        .to enqueue_sidekiq_job(worker).in(interval)
    end

    it 'fails when timestamps do not match' do
      interval = 1.minute
      expect {
        expect { worker.perform_in(interval) }
          .to enqueue_sidekiq_job(worker).in(2.minutes)
      }.to raise_error(/expected to enqueue.+in:/m)
    end

    it 'fails when the job was enuqued for now' do
      expect {
        expect { worker.perform_async }
          .to enqueue_sidekiq_job(worker).in(1.minute)
      }.to raise_error(/expected to enqueue.+in:/m)
    end
  end

  it 'matches when not specified at and scheduled for the future' do
    expect { worker.perform_in(1.day) }
      .to enqueue_sidekiq_job(worker)
    expect { worker.perform_at(1.day.from_now) }
      .to enqueue_sidekiq_job(worker)
  end

  context 'with arguments' do
    it 'fails with kwargs' do
      expect {
        expect { worker.perform_async }
          .to enqueue_sidekiq_job(worker).with(42, name: 'David')
      }.to raise_error(/keyword arguments serialization is not supported by Sidekiq/)
    end

    it 'passes with provided arguments' do
      expect { worker.perform_async(42, 'David') }
        .to enqueue_sidekiq_job(worker).with(42, 'David')
    end

    it 'supports provided argument matchers' do
      expect { worker.perform_async(42, 'David') }
        .to enqueue_sidekiq_job(worker).with(be > 41, a_string_including('Dav'))
    end

    it 'passes when negated and arguments do not match' do
      expect { worker.perform_async(42, 'David') }
        .not_to enqueue_sidekiq_job(worker).with(11, 'Phil')
    end

    it 'fails when arguments do not match' do
      expect {
        expect { worker.perform_async(42, 'David') }
          .to enqueue_sidekiq_job(worker).with(11, 'Phil')
      }.to raise_error(/expected to enqueue.+arguments:/m)
    end
  end
end
