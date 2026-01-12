# frozen_string_literal: true

require "json"

module RSpec
  module Sidekiq
    module NamedQueues
      class NullSet
        include Enumerable

        def initialize(store)
          @store = store
        end

        def each
          return enum_for(:each) unless block_given?

          items.each { |item| yield Entry.new(item) }
        end

        def scan(pattern)
          return enum_for(:scan, pattern) unless block_given?

          entries = items.select { |item| File.fnmatch?(pattern, item.to_json) }
          entries.each { |item| yield Entry.new(item) }
        end

        private

        def items
          []
        end

        class Entry
          attr_reader :item

          def initialize(item)
            @item = item
          end

          def klass
            item["class"]
          end

          def wrapped
            item["wrapped"]
          end

          def args
            item["args"]
          end

          def error_message
            item["error_message"]
          end

          def error_class
            item["error_class"]
          end

          def retry_count
            item["retry_count"]
          end

          def failed_at
            item["failed_at"]
          end
        end
      end
    end
  end
end
