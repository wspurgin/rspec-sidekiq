require 'spec_helper'

RSpec.describe 'Batch' do
  module Sidekiq
    module Batch
      class Status
      end
    end
  end

  load File.expand_path(File.join(File.dirname(__FILE__), '../../../lib/rspec/sidekiq/batch.rb'))

  describe 'NullObject' do
    describe '#method_missing' do
      it 'returns itself' do
        batch = Sidekiq::Batch.new
        expect(batch.non_existent_method).to eq(batch)
      end
    end
  end

  describe 'NullBatch' do
  end

  describe 'NullStatus' do
    let(:batch) {  Sidekiq::Batch.new }

    subject { batch.status }

    describe '#total' do
      it 'returns 0 when no jobs' do
        expect(subject.total).to eq(0)
      end

      it 'returns 1 when 1 job' do
        batch.jobs do
          TestWorker.perform_async('5')
        end

        expect(subject.total).to eq(1)
      end
    end

    describe '#failures' do
      it 'returns 0' do
        expect(subject.failures).to eq(0)
      end
    end

    describe '#bid' do
      it 'returns a bid' do
        expect(subject.bid).to_not be_nil
      end
    end

    describe '#join' do
      class MyCallback
        def on_event(status, options); end
      end

      class OtherCallback
        def foo(status, options); end
      end

      before(:each) do
        batch.on(:event, MyCallback, my_arg: 42)
        batch.on(:event, 'OtherCallback#foo', my_arg: 23)
      end

      it 'executes callbacks' do
        expect_any_instance_of(MyCallback).to receive(:on_event).with(subject, { my_arg: 42 })
        expect_any_instance_of(OtherCallback).to receive(:foo).with(subject, { my_arg: 23 })
        subject.join
      end
    end

    describe '#initialize' do
      it 'uses default argument values when none are provided' do
        expect { Sidekiq::Batch::Status.new }.to_not raise_error
      end
    end
  end
end