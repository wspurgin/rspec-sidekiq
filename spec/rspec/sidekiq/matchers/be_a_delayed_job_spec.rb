require "spec_helper"

describe 'delay call' do
  describe '.delayed_a_job_for' do
    class FooClass
      def bar(str)
        str
      end
    end

    it 'returns true if the method given has been delayed' do
      FooClass.delay.bar('hello!')
      expect('bar').to be_a_delayed_job

      expect('bar2').to_not be_a_delayed_job
      expect('ba').to_not be_a_delayed_job
      expect('foobar').to_not be_a_delayed_job
    end

    it 'validates the delay time' do
      FooClass.delay_for(3600).bar('hello!')

      expect('bar').to be_a_delayed_job(3600)

      expect('bar').to be_a_delayed_job
      expect('bar').to_not be_a_delayed_job(7200)
    end
  end
end