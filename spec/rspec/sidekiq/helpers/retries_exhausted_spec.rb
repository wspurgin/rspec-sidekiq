require 'spec_helper'

RSpec.describe 'Retries Exhausted block' do
  class FooClass < TestWorkerAlternative
    sidekiq_retries_exhausted do |msg, exception|
      bar('hello')
      foo(msg)
      baz(exception)
    end

    def self.bar(input)
    end

    def self.foo(msg)
    end

    def self.baz(exception)
    end
  end

  it 'executes whatever is within the block' do
    FooClass.within_sidekiq_retries_exhausted_block { expect(FooClass).to receive(:bar).with('hello') }
  end

  it 'passes message and exception to the block' do
    args = { 'args' => ['a', 'b']}
    exception = StandardError.new('something went wrong')
    FooClass.within_sidekiq_retries_exhausted_block(args, exception) do
      expect(FooClass).to receive(:foo).with(FooClass.default_retries_exhausted_message.merge(args))
      expect(FooClass).to receive(:baz).with(exception)
    end
  end

  it 'sets a default value for the message and exception' do
    FooClass.within_sidekiq_retries_exhausted_block do
      expect(FooClass).to receive(:foo).with(FooClass.default_retries_exhausted_message)
      expect(FooClass).to receive(:baz).with(FooClass.default_retries_exhausted_exception)
    end
  end
end
