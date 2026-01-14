# frozen_string_literal: true

require_relative "null_set"

module RSpec
  module Sidekiq
    module NamedQueues
      class NullScheduledSet < NullSet
        private

        def items
          @store.scheduled
        end
      end
    end
  end
end
