require 'spec_helper'

RSpec.describe RSpec::Sidekiq::Matchers::BeDeadable do
  let(:subject) { RSpec::Sidekiq::Matchers::BeDeadable.new 1 }
  let(:worker) { create_worker dead: 1 }

  describe '#be_deadable' do
    it 'returns instance' do
      expect(be_deadable 1).to be_a described_class
    end
  end

  describe 'expected usage' do
    it 'matches' do
      expect(worker).to be_deadable 1
    end

    context 'with negated' do
      it 'matches' do
        expect(worker).to_not be_deadable 0
      end
    end
  end

  describe '#failure_message' do
    it 'returns message' do
      subject.matches? worker
      expect(subject.failure_message).to eq "expected #{self.worker} to be \"#{subject.message_for(subject.instance_variable_get(:@expected_dead))}\" but got \"#{subject.message_for(subject.instance_variable_get(:@actual))}\""
    end
  end

  describe '#matches?' do
    context 'when expected equals actual' do
      it 'returns true' do
        expect(subject.matches? worker).to be true
      end
    end
    context 'when expected is not equal to actual' do
      it 'returns false' do
        expect(described_class.new(2).matches? worker). to be false
      end
    end
  end

  describe '#failure_message_when_negated' do
    it 'returns message' do
      subject.matches? worker
      expect(subject.failure_message_when_negated).to eq "expected #{subject.instance_variable_get(:@klass)} to be \"#{subject.message_for(!subject.instance_variable_get(:@expected_dead))}\" but it does"
    end
  end

  describe '#description' do
    it 'returns message' do
      expect(subject.description).to eq "be #{subject.message_for(!subject.instance_variable_get(:@expected_argument))} in queue"
    end
  end
end
