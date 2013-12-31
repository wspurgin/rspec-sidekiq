module RSpec
  module Sidekiq
    module Spec
      module Support
        module Factories
          def create_worker options = {}
            clazz_name = "Worker#{ rand(36 ** 10).to_s 36 }"
            clazz = Class.new do
              include ::Sidekiq::Worker

              sidekiq_options options

              def perform
              end
            end
            Object.const_set clazz_name, clazz
          end
        end
      end
    end
  end
end