module Sidekiq
  module Worker
    module ClassMethods
      def within_sidekiq_retries_exhausted_block user_msg = {}, &block
        block.call
        self.sidekiq_retries_exhausted_block.call default_retries_exhausted_args.merge(user_msg)
      end

      def default_retries_exhausted_args
        {
          'queue' => get_sidekiq_options[:worker],
          'class' => self.name,
          'args' => [],
          'error_message' => 'An error occured'
        }
      end
    end
  end
end