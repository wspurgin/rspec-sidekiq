if defined? Sidekiq::Batch
  module RSpec
    module Sidekiq
      class NullObject
        def initialize(*)
        end

        def method_missing(*args, &block)
          self
        end
      end

      class NullBatch < NullObject
        def jobs(*)
          yield
        end
      end

      class NullStatus < NullObject
        def join
          ::Sidekiq::Worker.drain_all
        end

        def total
          ::Sidekiq::Worker.jobs.size
        end
      end
    end
  end

  RSpec.configure do |config|
    config.before(:each) do
      if mocked_with_mocha?
        Sidekiq::Batch.stubs(:new) { RSpec::Sidekiq::NullBatch.new }
        Sidekiq::Batch::Status.stubs(:new) { RSpec::Sidekiq::NullStatus.new }
      else
        Sidekiq::Batch.stub(:new) { RSpec::Sidekiq::NullBatch.new }
        Sidekiq::Batch::Status.stub(:new) { RSpec::Sidekiq::NullStatus.new }
      end
    end
  end

  ## Helpers ----------------------------------------------
  def mocked_with_mocha?
    Sidekiq::Batch.respond_to? :stubs
  end
end