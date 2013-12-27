require "spec_helper"

describe "Have Enqueued Job matcher" do
  let(:matcher) { RSpec::Sidekiq::Matchers::HaveEnqueuedJob.new '8' }

  describe "expect syntax" do
    before do
      TestWorker.perform_async('5')
    end
    it "correctly matches" do
      expect(TestWorker).to have_enqueued_job('5')
    end

    it "correctly matches using a general matcher" do
      expect(TestWorker).to have_enqueued_job(an_instance_of(String))
    end

    context '#description' do
      it 'produces the correct description' do
        matcher.matches? TestWorker
        expect(matcher.description).to eq("have an enqueued TestWorker job with arguments 8")
      end
    end

    context '#failure_message' do
      it 'produces the correct failure_message' do
        matcher.matches? TestWorker
        expected_message = "expected to have an enqueued TestWorker job with arguments 8 but none found\n\n" +
          "found: [[\"5\"]]"
        expect(matcher.failure_message).to eq(expected_message)
      end
    end

    context '#negative_failure_message' do
      it 'produces the correct negative_failure_message' do
        matcher.matches? TestWorker
        expect(matcher.negative_failure_message).to eq("expected to not have an enqueued TestWorker job with arguments 8")
      end
    end
  end
end