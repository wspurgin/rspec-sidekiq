require "spec_helper"

describe "Batch" do
  module Sidekiq
    module Batch
      class Status
      end
    end
  end

  load File.expand_path(File.join(File.dirname(__FILE__), "../../../lib/rspec/sidekiq/batch.rb"))

  describe "NullStatus" do
    describe "#total" do
      it "returns 0 when no jobs" do
        null_status = RSpec::Sidekiq::NullStatus.new
        expect(null_status.total).to eq(0)
      end

      it "returns 1 when 1 job" do
        null_status = RSpec::Sidekiq::NullStatus.new
        TestWorker.perform_async('5')
        expect(null_status.total).to eq(1)
      end
    end
  end
end