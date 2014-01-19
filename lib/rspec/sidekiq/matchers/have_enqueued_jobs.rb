module RSpec
  module Sidekiq
    module Matchers
      def have_enqueued_jobs expected_number_of_jobs
        raise RuntimeError, "have_enqueued_jobs matcher has been removed from rspec-sidekiq 1.x.x. Use \"expect(Job).to have(2).jobs\" instead. See https://github.com/philostler/rspec-sidekiq/wiki/FAQ-&-Troubleshooting"
      end

      class HaveEnqueuedJobs
      end
    end
  end
end