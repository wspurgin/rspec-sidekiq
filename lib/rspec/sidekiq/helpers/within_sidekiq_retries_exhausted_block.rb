module Sidekiq
  module Worker
    module ClassMethods
      def within_sidekiq_retries_exhausted_block(user_msg = {}, exception = default_retries_exhausted_exception, &block)
        block.call
        sidekiq_retries_exhausted_block.call(default_retries_exhausted_message.merge(user_msg), exception)
      end

      def default_retries_exhausted_message
        {
          'queue' => get_sidekiq_options[:worker],
          'class' => name,
          'args' => [],
          'error_message' => 'An error occured'
        }
      end

      def default_retries_exhausted_exception
        StandardError.new('An error occured')
      end
    end
  end
end
