module Sidekiq
  module Worker
    module ClassMethods
      def within_sidekiq_retries_exhausted_block &block
        block.call

        self.sidekiq_retries_exhausted_block.call
      end
    end
  end
end