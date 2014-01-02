require "spec_helper"

describe RSpec::Sidekiq::Matchers::BeDelayed do
  let(:subject) { RSpec::Sidekiq::Matchers::BeDelayed.new }
  before(:each) do
    Object.delay_for(Time.now + 4000).nil?
    Object.delay.nil?
  end

  describe "expected usage" do
    it "matches" do
      expect(Object.method :nil?).to be_delayed
    end
  end

  describe "#be_delayed_job" do
    it "returns instance" do
      expect(be_delayed).to be_a RSpec::Sidekiq::Matchers::BeDelayed
    end
  end

  describe "#description" do
    it "returns description"
  end

  describe "#failure_message" do
    it "returns message"
  end

  describe "#matches?" do
    context "when condition matches" do
      it "returns true"
    end

    context "when condition does not match" do
      it "returns false"
    end
  end

  describe "#negative_failure_message" do
    it "returns message"
  end
end