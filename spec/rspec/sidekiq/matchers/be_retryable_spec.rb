require "spec_helper"

describe "Be Retryable matcher" do

  describe "expect syntax" do
    context "when retryable is number" do
      it "correctly matches" do
        expect(TestWorker).to be_retryable 5
      end
    end

    context "when retryable is true" do
      it "correctly matches" do
        expect(TestWorkerDefaults).to be_retryable true
      end
    end

    context "when retryable is false" do
      it "correctly matches" do
        expect(TestWorkerAlternative).to be_retryable false
      end
    end
  end

  describe "one liner syntax" do
    context "when retryable is number" do
      subject { TestWorker }
      expect_it { to be_retryable 5 }
    end

    context "when retryable is true" do
      subject { TestWorkerDefaults }
      expect_it { to be_retryable true }
    end

    context "when retryable is false" do
      subject { TestWorkerAlternative }
      expect_it { to be_retryable false }
    end
  end
end