require "spec_helper"

describe "Have Enqueued Job matcher" do
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
  end
end