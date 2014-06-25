require "spec_helper"

describe RSpec::Sidekiq::Matchers::HaveEnqueuedJob do
  let(:args){ ["string", 1, true] }
  let(:matcher){ RSpec::Sidekiq::Matchers::HaveEnqueuedJob.new args }
  let(:worker) { create_worker }
  let(:a_minute_from_now){ Time.now + 60 }
  subject{ matcher }

  describe "expected usage" do
    it "matches" do
      worker.perform_async(*args)
      expect(worker).to(have_enqueued_job(*args))
    end

    context 'chained with :to_be_performed_at' do
      it "matches" do
        worker.perform_in a_minute_from_now, *args
        expect(worker).to(have_enqueued_job(*args).to_be_performed_at(a_minute_from_now))
      end
    end

    context 'chained with :to_be_performed_it' do
      it "matches" do
        worker.perform_in a_minute_from_now, *args
        expect(worker).to(have_enqueued_job(*args).to_be_performed_in(a_minute_from_now))
      end
    end
  end

  describe '#matchers' do
    it 'is an array of 1 element' do
      expect(subject.matchers.count).to eq 1
    end

    it 'is an array with an instance of ArgumentsMatcher' do
      expect(subject.matchers[0]).to be_instance_of(RSpec::Sidekiq::Matchers::HaveEnqueuedJob::ArgumentsMatcher)
    end

    context 'chained with :to_be_performed_at' do
      subject { matcher.to_be_performed_at(a_minute_from_now) }

      it 'is an array of 2 elements' do
        expect(subject.matchers.count).to eq 2
      end

      it 'is an array with an instance of ArgumentsMatcher and an instance of TimeMatcher' do
        expect(subject.matchers[0]).to be_instance_of(RSpec::Sidekiq::Matchers::HaveEnqueuedJob::ArgumentsMatcher)
        expect(subject.matchers[1]).to be_instance_of(RSpec::Sidekiq::Matchers::HaveEnqueuedJob::TimeMatcher)
      end
    end
  end

  describe RSpec::Sidekiq::Matchers::HaveEnqueuedJob::ArgumentsMatcher do
    subject do
      RSpec::Sidekiq::Matchers::HaveEnqueuedJob::ArgumentsMatcher.new(args)
    end

    before(:each) do
      worker.perform_async(*args)
    end

    describe '#matches?' do
      context 'when Sidekiq::Testing is enabled' do
        context "when condition matches" do
          it "returns true" do
            expect(subject.matches? worker).to be_true
          end
        end

        context "when condition does not match" do
          before(:each) { Sidekiq::Worker.clear_all }

          it "returns false" do
            expect(subject.matches? worker).to be_false
          end
        end
      end

      context 'when Sidekiq::Testing is disabled' do
        around(:each) { |example| Sidekiq::Testing.disable!{ example.run } }
        after(:each) { Sidekiq::Queue.all.each(&:clear) }

        context "when condition matches" do
          it "returns true" do
            expect(subject.matches? worker).to be_true
          end
        end

        context "when condition does not match" do
          it "returns false" do
            Sidekiq::Queue.all.each(&:clear)
            expect(subject.matches? worker).to be_false
          end
        end
      end
    end
  end

  describe RSpec::Sidekiq::Matchers::HaveEnqueuedJob::TimeMatcher do
    subject do
      RSpec::Sidekiq::Matchers::HaveEnqueuedJob::TimeMatcher.new(a_minute_from_now)
    end

    before(:each) do
      worker.perform_in a_minute_from_now, *args
    end

    describe '#matches?' do
      context 'when Sidekiq::Testing is enabled' do
        context "when condition matches" do
          it "returns true" do
            expect(subject.matches? worker).to be_true
          end
        end

        context "when condition does not match" do
          it "returns false" do
            Sidekiq::Worker.clear_all
            expect(subject.matches? worker).to be_false
          end
        end
      end

      context 'when Sidekiq::Testing is disabled' do
        around(:each) { |example| Sidekiq::Testing.disable!{ example.run } }
        after(:each) { Sidekiq::Queue.all.each(&:clear) }

        context "when condition matches" do
          it "returns true" do
            expect(subject.matches? worker).to be_true
          end
        end

        context "when condition does not match" do
          it "returns false" do
            Sidekiq::ScheduledSet.new.each(&:delete)
            expect(subject.matches? worker).to be_false
          end
        end
      end
    end
  end
end
