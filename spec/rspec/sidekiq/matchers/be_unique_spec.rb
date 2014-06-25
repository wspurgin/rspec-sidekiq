require "spec_helper"

describe RSpec::Sidekiq::Matchers::BeUnique do
  shared_context "a unique worker" do
    before(:each) { subject.matches? @worker }

    describe "expected usage" do
      it "matches" do
        expect(@worker).to be_unique
      end

      describe "#failure_message" do
        it "returns message" do
          expect(subject.failure_message).to eq "expected #{@worker} to be unique in the queue"
        end
      end

    end

    describe "#matches?" do
      context "when condition matches" do
        it "returns true" do
          expect(subject.matches? @worker).to be true
        end
      end

      context "when condition does not match" do
        it "returns false" do
          expect(subject.matches? create_worker unique: false).to be false
        end
      end

      describe "#negative_failure_message" do
        it "returns message" do
          expect(subject.negative_failure_message).to eq "expected #{@worker} to not be unique in the queue"
        end
      end
    end
  end

  context "a scheduled worker" do
    before { @worker =  create_worker unique: :all }
    include_context "a unique worker"
  end

  context "a regular worker" do
    before { @worker =  create_worker unique: true}
    include_context "a unique worker"
  end

  describe "#be_unique" do
    it "returns instance" do
      expect(be_unique).to be_a RSpec::Sidekiq::Matchers::BeUnique
    end
  end

  describe "#description" do
    it "returns description" do
      expect(subject.description).to eq "be unique in the queue"
    end
  end
end
