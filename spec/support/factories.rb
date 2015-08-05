module RSpec
  module Sidekiq
    module Spec
      module Support
        module Factories
          def create_worker(options = {})
            clazz_name = "Worker#{ rand(36**10).to_s 36 }"
            clazz = Class.new do
              include ::Sidekiq::Worker

              sidekiq_options options

              def perform
              end
            end
            Object.const_set clazz_name, clazz
          end

          def create_active_job(options = {})
            clazz_name = "ActiveJob#{ rand(36**10).to_s 36 }"
            clazz = Class.new(ActiveJob::Base) do
              queue_as options

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
