require 'spec_helper'

describe 'Retries Exhausted block' do

  class FooClass < TestWorkerAlternative
    sidekiq_retries_exhausted do |msg|
      bar('hello')
      foo(msg)
    end

    def self.bar(input)
    end

    def self.foo(msg)
    end
  end

  it 'executes whatever is within the block' do
    FooClass.within_sidekiq_retries_exhausted_block { expect(FooClass).to receive(:bar).with('hello') }
  end

  it 'passes arguments to the block' do
    args = {'args' => ['a', 'b']}
    FooClass.within_sidekiq_retries_exhausted_block(args) do
      expect(FooClass).to receive(:foo).with(FooClass.default_retries_exhausted_args.merge(args))
    end
  end

end
