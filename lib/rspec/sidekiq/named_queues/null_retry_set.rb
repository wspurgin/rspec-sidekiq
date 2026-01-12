# frozen_string_literal: true

require_relative "null_set"

module RSpec
  module Sidekiq
    module NamedQueues
      class NullRetrySet < NullSet
        private

        def items
          @store.retry_set
        end
      end
    end
  end
end
