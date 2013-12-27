require 'spec_helper'

describe 'Retries Exhausted block' do

  class FooClass < TestWorkerAlternative
    sidekiq_retries_exhausted do |msg|
      bar('hello')
    end

    def self.bar(input)
    end
  end

  it 'executes whatever is within the block' do
    FooClass.within_sidekiq_retries_exhausted_block { expect(FooClass).to receive(:bar).with('hello') }
  end

end
