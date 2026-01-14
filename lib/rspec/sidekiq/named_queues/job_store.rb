# frozen_string_literal: true

require "securerandom"

module RSpec
  module Sidekiq
    module NamedQueues
      class JobStore
        attr_reader :scheduled, :retry_set, :dead

        def initialize
          @scheduled = []
          @retry_set = []
          @dead = []
        end

        def push(item)
          jid = extract_or_assign_jid(item)
          payload = normalize_item(item)
          payload["jid"] ||= jid

          if payload.key?("at")
            @scheduled << payload
          end

          payload
        end

        def add_retry(item)
          @retry_set << normalize_item(item)
        end

        def add_dead(item)
          @dead << normalize_item(item)
        end

        def clear!
          @scheduled.clear
          @retry_set.clear
          @dead.clear
        end

        private

        def normalize_item(item)
          item ||= {}
          if item.is_a?(Hash)
            return item.each_with_object({}) do |(key, value), hash|
              hash[key.to_s] = value
            end
          end

          item.to_h.each_with_object({}) do |(key, value), hash|
            hash[key.to_s] = value
          end
        end

        def extract_or_assign_jid(item)
          return SecureRandom.hex(12) unless item.is_a?(Hash)

          item["jid"] ||= item[:jid]
          item["jid"] ||= SecureRandom.hex(12)
        end
      end
    end
  end
end
