# frozen_string_literal: true

require "spec_helper"

RSpec.describe RSpec::Sidekiq::Matchers::BeDelayed do
  if RSpec.configuration.sidekiq_gte_7
    it "should raise an error" do
      expect { described_class.new }.to raise_error(/Use of the be_delayed matcher with Sidekiq 7\+ is not possible/)
    end
  else
    let(:delay_subject) { RSpec::Sidekiq::Matchers::BeDelayed.new }
    let(:delay_with_arguments_subject) { RSpec::Sidekiq::Matchers::BeDelayed.new Object }
    let(:delay_for_subject) { RSpec::Sidekiq::Matchers::BeDelayed.new.for 3600 }
    let(:delay_for_with_arguments_subject) { RSpec::Sidekiq::Matchers::BeDelayed.new(Object).for 3600 }
    let(:delay_until_subject) { RSpec::Sidekiq::Matchers::BeDelayed.new.until Time.now + 3600 }
    let(:delay_until_with_arguments_subject) { RSpec::Sidekiq::Matchers::BeDelayed.new(Object).until Time.now + 3600 }

    around(:each) do |example|
      travel_to Time.new(2023, 8, 1, 0, 0, 0, "-05:00") do
        example.run
      end
    end

    before(:each) do
      delay_subject.matches? Object.method :nil?
      delay_with_arguments_subject.matches? Object.method :is_a?

      delay_for_subject.matches? Object.method :nil?
      delay_for_with_arguments_subject.matches? Object.method :is_a?

      delay_until_subject.matches? Object.method :nil?
      delay_until_with_arguments_subject.matches? Object.method :is_a?
    end

    describe 'expected usage' do
      it 'matches' do
        Object.delay_for(3600).is_a? Object

        expect(Object.method :is_a?).to be_delayed(Object).for 3600
      end
    end

    describe '#be_delayed_job' do
      it 'returns instance' do
        expect(be_delayed).to be_a RSpec::Sidekiq::Matchers::BeDelayed
      end
    end

    describe '#description' do
      context 'when expected is a delay' do
        it 'returns description' do
          expect(delay_subject.description).to eq 'be delayed'
        end
      end

      context 'when expected is a delay with arguments' do
        it 'returns description' do
          expect(delay_with_arguments_subject.description).to eq 'be delayed with arguments [Object]'
        end
      end

      context 'when expected is a delay for' do
        it 'returns description' do
          expect(delay_for_subject.description).to eq 'be delayed for 3600 seconds'
        end
      end

      context 'when expected is a delay for with arguments' do
        it 'returns description' do
          expect(delay_for_with_arguments_subject.description).to eq 'be delayed for 3600 seconds with arguments [Object]'
        end
      end

      context 'when expected is a delay until' do
        it 'returns description' do
          expect(delay_until_subject.description).to eq "be delayed until #{Time.now + 3600}"
        end
      end

      context 'when expected is a delay until with arguments' do
        it 'returns description' do
          expect(delay_until_with_arguments_subject.description).to eq "be delayed until #{Time.now + 3600} with arguments [Object]"
        end
      end
    end

    describe '#failure_message' do
      context 'when expected is a delay' do
        it 'returns message' do
          expect(delay_subject.failure_message).to eq 'expected Object.nil? to be delayed'
        end
      end

      context 'when expected is a delay with arguments' do
        it 'returns message' do
          expect(delay_with_arguments_subject.failure_message).to eq 'expected Object.is_a? to be delayed with arguments [Object]'
        end
      end

      context 'when expected is a delay for' do
        it 'returns message' do
          expect(delay_for_subject.failure_message).to eq 'expected Object.nil? to be delayed for 3600 seconds'
        end
      end

      context 'when expected is a delay for with arguments' do
        it 'returns message' do
          expect(delay_for_with_arguments_subject.failure_message).to eq 'expected Object.is_a? to be delayed for 3600 seconds with arguments [Object]'
        end
      end

      context 'when expected is a delay until' do
        it 'returns message' do
          expect(delay_until_subject.failure_message).to eq "expected Object.nil? to be delayed until #{Time.now + 3600}"
        end
      end

      context 'when expected is a delay until with arguments' do
        it 'returns message' do
          expect(delay_until_with_arguments_subject.failure_message).to eq "expected Object.is_a? to be delayed until #{Time.now + 3600} with arguments [Object]"
        end
      end
      end

    describe '#matches?' do
      context 'when condition matches' do
        context 'when expected is a delay' do
          it 'returns true' do
            Object.delay.nil?

            expect(delay_subject.matches? Object.method :nil?).to be true
          end

          context "and actual contains arguments" do
            it "returns true" do
              # Acutal has arugment
              Object.delay.is_a? Object

              # Expected didn't specify any arguemtns to match
              expect(delay_subject.matches? Object.method :is_a?).to be true
            end
          end
        end

        context 'when expected is a delay with arguments' do
          it 'returns true' do
            Object.delay.is_a? Object

            expect(delay_with_arguments_subject.matches? Object.method :is_a?).to be true
          end

          context "and expected uses builtin matchers" do
            let(:delay_with_arguments_subject) { RSpec::Sidekiq::Matchers::BeDelayed.new anything }
            it "returns true" do
              Object.delay.is_a? Object
              expect(delay_with_arguments_subject.matches? Object.method(:is_a?)).to be true
            end
          end
        end

        context 'when expected is a delay for' do
          it 'returns true' do
            Object.delay_for(3600).nil?

            expect(delay_for_subject.matches? Object.method :nil?).to be true
          end
        end

        context 'when expected is a delay for with arguments' do
          it 'returns true' do
            Object.delay_for(3600).is_a? Object

            expect(delay_for_with_arguments_subject.matches? Object.method :is_a?).to be true
          end
        end

        context 'when expected is a delay until' do
          it 'returns true' do
            Object.delay_until(Time.now + 3600).nil?

            expect(delay_until_subject.matches? Object.method :nil?).to be true
          end
        end

        context 'when expected is a delay until with arguments' do
          it 'returns true' do
            Object.delay_until(Time.now + 3600).is_a? Object

            expect(delay_until_with_arguments_subject.matches? Object.method :is_a?).to be true
          end
        end
      end

      context 'when condition does not match' do
        context 'when expected is a delay' do
          it 'returns false' do
            expect(delay_subject.matches? Object.method :nil?).to be false
          end
        end

        context 'when expected is a delay with arguments' do
          it 'returns false' do
            expect(delay_with_arguments_subject.matches? Object.method :is_a?).to be false
          end
        end

        context 'when expected is a delay for' do
          it 'returns false' do
            expect(delay_for_subject.matches? Object.method :nil?).to be false
          end
        end

        context 'when expected is a delay for with arguments' do
          it 'returns false' do
            expect(delay_for_with_arguments_subject.matches? Object.method :is_a?).to be false
          end
        end

        context 'when expected is a delay until' do
          it 'returns false' do
            expect(delay_until_subject.matches? Object.method :nil?).to be false
          end
        end

        context 'when expected is a delay until with arguments' do
          it 'returns false' do
            expect(delay_until_with_arguments_subject.matches? Object.method :is_a?).to be false
          end
        end
        end
      end

    describe '#failure_message_when_negated' do
      context 'when expected is a delay' do
        it 'returns message' do
          expect(delay_subject.failure_message_when_negated).to eq 'expected Object.nil? to not be delayed'
        end
      end

      context 'when expected is a delay with arguments' do
        it 'returns message' do
          expect(delay_with_arguments_subject.failure_message_when_negated).to eq 'expected Object.is_a? to not be delayed with arguments [Object]'
        end
      end

      context 'when expected is a delay for' do
        it 'returns message' do
          expect(delay_for_subject.failure_message_when_negated).to eq 'expected Object.nil? to not be delayed for 3600 seconds'
        end
      end

      context 'when expected is a delay for with arguments' do
        it 'returns message' do
          expect(delay_for_with_arguments_subject.failure_message_when_negated).to eq 'expected Object.is_a? to not be delayed for 3600 seconds with arguments [Object]'
        end
      end

      context 'when expected is a delay until' do
        it 'returns message' do
          expect(delay_until_subject.failure_message_when_negated).to eq "expected Object.nil? to not be delayed until #{Time.now + 3600}"
        end
      end

      context 'when expected is a delay until with arguments' do
        it 'returns message' do
          expect(delay_until_with_arguments_subject.failure_message_when_negated).to eq "expected Object.is_a? to not be delayed until #{Time.now + 3600} with arguments [Object]"
        end
      end
    end
  end
end
