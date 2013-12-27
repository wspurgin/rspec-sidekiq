require "spec_helper"

describe "Have Enqueued Jobs matcher" do
  let(:one_job_matcher) { RSpec::Sidekiq::Matchers::HaveEnqueuedJobs.new 1 }
  let(:two_jobs_matcher) { RSpec::Sidekiq::Matchers::HaveEnqueuedJobs.new 2 }
  describe "expect syntax" do
    before do
      TestWorker.perform_async('5')
      TestWorker.perform_async('4')
      TestWorker.perform_async('3')
    end

    context '#description' do
      it 'produces the correct description for a one job matcher' do
        one_job_matcher.matches? TestWorker
        expect(one_job_matcher.description).to eq("have 1 enqueued TestWorker job")
      end

      it 'produces the correct description for a multiple job matcher' do
        two_jobs_matcher.matches? TestWorker
        expect(two_jobs_matcher.description).to eq("have 2 enqueued TestWorker jobs")
      end
    end

    context '#failure_message' do
      it 'produces the correct failure_message for a one job matcher' do
        one_job_matcher.matches? TestWorker
        expect(one_job_matcher.failure_message).to eq("expected TestWorker to have 1 enqueued job but got 3")
      end

      it 'produces the correct failure_message for a multiple job matcher' do
        two_jobs_matcher.matches? TestWorker
        expect(two_jobs_matcher.failure_message).to eq("expected TestWorker to have 2 enqueued jobs but got 3")
      end
    end

    context '#negative_failure_message' do
      it 'produces the correct negative_failure_message for a one job matcher' do
        one_job_matcher.matches? TestWorker
        expect(one_job_matcher.negative_failure_message).to eq("expected TestWorker to not have 1 enqueued job")
      end

      it 'produces the correct negative_failure_message for a multiple job matcher' do
        two_jobs_matcher.matches? TestWorker
        expect(two_jobs_matcher.negative_failure_message).to eq("expected TestWorker to not have 2 enqueued jobs")
      end
    end

    context '#matches?' do
      context 'when the condition matches' do
        it "correctly matches" do
          expect(TestWorker).to have_enqueued_jobs(3)
        end
      end

      context "when condition does not match" do
        it "returns false" do
          expect(two_jobs_matcher.matches? TestWorker).to be false
        end
      end
    end
  end
end