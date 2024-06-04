# frozen_string_literal: true

require 'rspec/core'

if defined? Sidekiq::Batch
  module RSpec
    module Sidekiq
      class NullObject
        def method_missing(*args, &block)
          self
        end
      end

      ##
      # Sidekiq::Batch is a Sidekiq::Pro feature. However the general consensus is
      # that, by defeault, you can't test without redis. RSpec::Sidekiq includes
      # a "null object" pattern implementation to mock Batches. This will mock
      # Sidekiq::Batch and prevent it from using Redis.
      #
      # This is _opt-in_ only feature.
      #
      #     RSpec.describe "Using mocked batches", stub_batches: true do
      #       it "uses mocked batches" do
      #         batch = Sidekiq::Batch.new
      #         batch.jobs do
      #           SomeJob.perform_async 123
      #         end
      #
      #         expect(SomeJob).to have_enqueued_sidekiq_job
      #       end
      #     end
      class NullBatch < NullObject
        attr_accessor :description
        attr_reader :bid

        def initialize(bid = nil)
          @bid = bid || SecureRandom.hex(8)
          @callbacks = []
        end

        def status
          NullStatus.new(@bid, @callbacks)
        end

        def on(*args)
          @callbacks << args
        end

        def jobs(*)
          yield
        end
      end

      class NullStatus < NullObject
        attr_reader :bid

        def initialize(bid = SecureRandom.hex(8), callbacks = [])
          @bid = bid
          @callbacks = callbacks
        end

        def failures
          0
        end

        def join
          ::Sidekiq::Worker.drain_all

          @callbacks.each do |event, callback, options|
            if event != :success || failures == 0
              case callback
              when Class
                callback.new.send("on_#{event}", self, options)
              when String
                klass, meth = callback.split('#')
                klass.constantize.new.send(meth, self, options)
              else
                raise ArgumentError, 'Unsupported callback notation'
              end
            end
          end
        end

        def total
          ::Sidekiq::Worker.jobs.size
        end
      end
    end
  end

  # :nocov:
  RSpec.configure do |config|
    config.before(:each) do |example|
      next unless example.metadata[:stub_batches] == true

      if mocked_with_mocha?
        Sidekiq::Batch.stubs(:new) { RSpec::Sidekiq::NullBatch.new }
      else
        allow(Sidekiq::Batch).to receive(:new)  { RSpec::Sidekiq::NullBatch.new }
        allow(Sidekiq::Batch::Status).to receive(:new)  { RSpec::Sidekiq::NullStatus.new }
      end
    end
  end

  ## Helpers ----------------------------------------------
  def mocked_with_mocha?
    Sidekiq::Batch.respond_to? :stubs
  end
  # :nocov:
end
