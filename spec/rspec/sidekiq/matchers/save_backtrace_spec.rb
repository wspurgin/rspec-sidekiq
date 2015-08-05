require 'spec_helper'

RSpec.describe RSpec::Sidekiq::Matchers::SaveBacktrace do
  let(:specific_subject) { RSpec::Sidekiq::Matchers::SaveBacktrace.new 2 }
  let(:specific_worker) { create_worker backtrace: 2 }
  let(:default_subject) { RSpec::Sidekiq::Matchers::SaveBacktrace.new true }
  let(:default_worker) { create_worker backtrace: true }
  let(:negative_subject) { RSpec::Sidekiq::Matchers::SaveBacktrace.new false }
  let(:negative_worker) { create_worker backtrace: false }
  before(:each) do
    specific_subject.matches? specific_worker
    default_subject.matches? default_worker
    negative_subject.matches? negative_worker
  end

  describe 'expected usage' do
    it 'matches' do
      expect(default_worker).to save_backtrace true
      expect(default_worker).to save_backtrace
    end

    it 'negative usage' do
      expect(negative_worker).to save_backtrace false
      expect(negative_worker).to_not save_backtrace
    end
  end

  describe '#save_backtrace' do
    it 'returns instance' do
      expect(save_backtrace true).to be_a RSpec::Sidekiq::Matchers::SaveBacktrace
      expect(save_backtrace).to be_a RSpec::Sidekiq::Matchers::SaveBacktrace
    end
  end

  describe '#description' do
    context 'when expected is a number' do
      it 'returns description' do
        expect(specific_subject.description).to eq 'save 2 lines of error backtrace'
      end
    end

    context 'when expected is true' do
      it 'returns description' do
        expect(default_subject.description).to eq 'save error backtrace'
      end
    end

    context 'when expected is false' do
      it 'returns description' do
        expect(negative_subject.description).to eq 'not save error backtrace'
      end
    end
  end

  describe '#failure_message' do
    context 'when expected is a number' do
      it 'returns message' do
        expect(specific_subject.failure_message).to eq "expected #{specific_worker} to save 2 lines of error backtrace but got 2"
      end
    end

    context 'when expected is true' do
      it 'returns message' do
        expect(default_subject.failure_message).to eq "expected #{default_worker} to save error backtrace but got true"
      end
    end

    context 'when expected is false' do
      it 'returns message' do
        expect(negative_subject.failure_message).to eq "expected #{negative_worker} to not save error backtrace but got false"
      end
    end
  end

  describe '#matches?' do
    context 'when condition matches' do
      context 'when expected is a number' do
        it 'returns true' do
          expect(specific_subject.matches? specific_worker).to be true
        end
      end

      context 'when expected is true' do
        it 'returns true' do
          expect(default_subject.matches? default_worker).to be true
        end
      end

      context 'when expected is false' do
        it 'returns true' do
          expect(negative_subject.matches? negative_worker).to be true
        end
      end
    end

    context 'when condition does not match' do
      context 'when expected is a number' do
        it 'returns false' do
          expect(specific_subject.matches? default_worker).to be false
        end
      end

      context 'when expected is true' do
        it 'returns false' do
          expect(default_subject.matches? negative_worker).to be false
        end
      end

      context 'when expected is false' do
        it 'returns false' do
          expect(negative_subject.matches? specific_worker).to be false
        end
      end
    end
  end

  describe '#failure_message_when_negated' do
    context 'when expected is a number' do
      it 'returns message' do
        expect(specific_subject.failure_message_when_negated).to eq "expected #{specific_worker} to not save 2 lines of error backtrace"
      end
    end

    context 'when expected is true' do
      it 'returns message' do
        expect(default_subject.failure_message_when_negated).to eq "expected #{default_worker} to not save error backtrace"
      end
    end

    context 'when expected is false' do
      it 'returns message' do
        expect(negative_subject.failure_message_when_negated).to eq "expected #{negative_worker} to save error backtrace"
      end
    end
  end
end
