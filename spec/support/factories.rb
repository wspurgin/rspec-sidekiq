module RSpec
  module Sidekiq
    module Spec
      module Support
        module Factories
          def create_worker options = {}
            Class.new do
              include ::Sidekiq::Worker

              sidekiq_options options

              def perform
              end
            end
          end
        end
      end
    end
  end
end