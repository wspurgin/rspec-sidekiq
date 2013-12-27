require "spec_helper"

describe RSpec::Sidekiq::Matchers::HaveEnqueuedJobs do
  describe "#have_enqueued_jobs" do
    it "raise error" do
      expect{ have_enqueued_jobs 0 }.to raise_error RuntimeError, "have_enqueued_jobs matcher has been removed from rspec-sidekiq 1.x.x. Use \"expect(Job).to have(2).jobs\" instead. See https://github.com/philostler/rspec-sidekiq/wiki/FAQ-&-Troubleshooting"
    end
  end
end