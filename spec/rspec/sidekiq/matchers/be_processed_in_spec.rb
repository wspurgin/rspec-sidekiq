require 'spec_helper'

RSpec.describe RSpec::Sidekiq::Matchers::BeProcessedIn do
  let(:symbol_subject) { RSpec::Sidekiq::Matchers::BeProcessedIn.new :a_queue }
  let(:symbol_worker) { create_worker queue: :a_queue }
  let(:string_subject) { RSpec::Sidekiq::Matchers::BeProcessedIn.new 'a_queue' }
  let(:string_worker) { create_worker queue: 'a_queue' }
  let(:active_job) { create_active_job :mailers }

  before(:each) do
    symbol_subject.matches? symbol_worker
    string_subject.matches? string_worker
  end

  describe 'expected usage' do
    it 'matches' do
      expect(symbol_worker).to be_processed_in :a_queue
    end

    it 'matches on an ActiveJob' do
      expect(active_job).to be_processed_in :mailers
    end
  end

  describe '#be_processed_in' do
    it 'returns instance' do
      expect(be_processed_in :a_queue).to be_a RSpec::Sidekiq::Matchers::BeProcessedIn
    end
  end

  describe '#description' do
    context 'when expected is a symbol' do
      it 'returns description' do
        expect(symbol_subject.description).to eq "be processed in the \"a_queue\" queue"
      end
    end

    context 'when expected is a string' do
      it 'returns description' do
        expect(string_subject.description).to eq "be processed in the \"a_queue\" queue"
      end
    end
  end

  describe '#failure_message' do
    context 'when expected is a symbol' do
      it 'returns message' do
        expect(symbol_subject.failure_message).to eq "expected #{symbol_worker} to be processed in the \"a_queue\" queue but got \"a_queue\""
      end
    end

    context 'when expected is a string' do
      it 'returns message' do
        expect(string_subject.failure_message).to eq "expected #{string_worker} to be processed in the \"a_queue\" queue but got \"a_queue\""
      end
    end
  end

  describe '#matches?' do
    context 'when condition matches' do
      context 'when expected is a symbol' do
        it 'returns true' do
          expect(symbol_subject.matches? symbol_worker).to be true
        end
      end

      context 'when expected is a symbol and actual is string' do
        it 'returns true' do
          expect(symbol_subject.matches? string_worker).to be true
        end
      end

      context 'when expected is a string' do
        it 'returns true' do
          expect(string_subject.matches? string_worker).to be true
        end
      end

      context 'when expected is a string and actual is symbol' do
        it 'returns true' do
          expect(string_subject.matches? symbol_worker).to be true
        end
      end
    end

    context 'when condition does not match' do
      context 'when expected is a symbol' do
        it 'returns false' do
          expect(symbol_subject.matches? create_worker queue: :another_queue).to be false
        end
      end

      context 'when expected is a string' do
        it 'returns false' do
          expect(string_subject.matches? create_worker queue: 'another_queue').to be false
        end
      end
    end
  end

  describe '#failure_message_when_negated' do
    context 'when expected is a symbol' do
      it 'returns message' do
        expect(symbol_subject.failure_message_when_negated).to eq "expected #{symbol_worker} to not be processed in the \"a_queue\" queue"
      end
    end

    context 'when expected is a string' do
      it 'returns message' do
        expect(string_subject.failure_message_when_negated).to eq "expected #{string_worker} to not be processed in the \"a_queue\" queue"
      end
    end
  end
end
