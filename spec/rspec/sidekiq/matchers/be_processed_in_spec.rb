require "spec_helper"

describe "Be Processed In matcher" do
  subject { TestWorker }

  describe "expect syntax" do
    context "when queue is specified as a string" do
      it "correctly matches" do
        expect(TestWorker).to be_processed_in "data"
      end
    end

    context "when queue is specified as a symbol" do
      it "correctly matches" do
        expect(TestWorker).to be_processed_in :data
      end
    end
  end

  describe "one liner syntax" do
    context "when queue is specified as a string" do
      expect_it { to be_processed_in "data" }
    end

    context "when queue is specified as a symbol" do
      expect_it { to be_processed_in :data }
    end
  end
end