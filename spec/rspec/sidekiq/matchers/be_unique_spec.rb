require "spec_helper"

describe "Be Unique matcher" do
  subject { TestWorker }

  describe "expect syntax" do
    it "correctly matches" do
      expect(TestWorker).to be_unique
    end
  end

  describe "one liner syntax" do
    expect_it { to be_unique }
  end  
end