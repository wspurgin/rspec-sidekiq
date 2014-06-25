require "rspec/core"

if defined? Sidekiq::Batch
  module RSpec
    module Sidekiq
      class NullObject
        def method_missing(*args, &block)
          self
        end
      end

      class NullBatch < NullObject
        attr_reader :bid

        def initialize(bid = nil)
          @bid = bid || SecureRandom.hex(8)
        end

        def status
          NullStatus.new(@bid)
        end

        def jobs(*)
          yield
        end
      end

      class NullStatus < NullObject
        attr_reader :bid

        def initialize(bid)
          @bid = bid
        end

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
      else
        Sidekiq::Batch.stub(:new) { RSpec::Sidekiq::NullBatch.new }
      end
    end
  end

  ## Helpers ----------------------------------------------
  def mocked_with_mocha?
    Sidekiq::Batch.respond_to? :stubs
  end
end
