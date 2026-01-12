# frozen_string_literal: true

require_relative "null_set"

module RSpec
  module Sidekiq
    module NamedQueues
      class NullDeadSet < NullSet
        private

        def items
          @store.dead
        end
      end
    end
  end
end
