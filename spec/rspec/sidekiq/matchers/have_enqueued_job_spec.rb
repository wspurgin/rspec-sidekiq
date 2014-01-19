require "spec_helper"

describe RSpec::Sidekiq::Matchers::HaveEnqueuedJob do
  let(:argument_subject) { RSpec::Sidekiq::Matchers::HaveEnqueuedJob.new ["string", 1, true] }
  let(:matcher_subject) { RSpec::Sidekiq::Matchers::HaveEnqueuedJob.new [an_instance_of(String), an_instance_of(Fixnum), true] }
  let(:worker) { create_worker }
  before(:each) do
    worker.perform_async "string", 1, true
    argument_subject.matches? worker
  end

  describe "expected usage" do
    it "matches" do
      expect(worker).to have_enqueued_job "string", 1, true
    end
  end

  describe "#have_enqueued_job" do
    it "returns instance" do
      expect(have_enqueued_job).to be_a RSpec::Sidekiq::Matchers::HaveEnqueuedJob
    end
  end

  describe "#description" do
    it "returns description" do
      expect(argument_subject.description).to eq "have an enqueued #{worker} job with arguments [\"string\", 1, true]"
    end
  end

  describe "#failure_message" do
    it "returns message" do
      expect(argument_subject.failure_message).to eq "expected to have an enqueued #{worker} job with arguments [\"string\", 1, true]\n\nfound: [[\"string\", 1, true]]"
    end
  end

  describe "#matches?" do
    context "when condition matches" do
      context "when expected are arguments" do
        it "returns true" do
          expect(argument_subject.matches? worker).to be true
        end
      end

      context "when expected are matchers" do
        it "returns true" do
          expect(matcher_subject.matches? worker).to be true
        end
      end
    end

    context "when condition does not match" do
      before(:each) { Sidekiq::Worker.clear_all }

      context "when expected are arguments" do
        it "returns false" do
          expect(argument_subject.matches? worker).to be false
        end
      end

      context "when expected are matchers" do
        it "returns false" do
          expect(matcher_subject.matches? worker).to be false
        end
      end
    end
  end

  describe "#negative_failure_message" do
    it "returns message" do
      expect(argument_subject.negative_failure_message).to eq "expected to not have an enqueued #{worker} job with arguments [\"string\", 1, true]"
    end
  end
end