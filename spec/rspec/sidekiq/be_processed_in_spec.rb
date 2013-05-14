require 'spec_helper'

class AwesomeJob
  include Sidekiq::Worker
  sidekiq_options :queue => :download

  def perform
  end

end

class AwesomeJobDefault
  include Sidekiq::Worker

  def perform
  end

end

describe 'be_processed_in' do

  it 'should correctly match a queue specified as a symbol' do
    expect(AwesomeJob.new).to be_processed_in :download
  end

  it 'should correctly match a queue specified as a string' do
    expect(AwesomeJob.new).to be_processed_in 'download'
  end

  it 'should correctly match the default queue specified as a symbol' do
    expect(AwesomeJobDefault.new).to be_processed_in :default
  end

  it 'should correctly match the default queue specified as a string' do
    expect(AwesomeJobDefault.new).to be_processed_in 'default'
  end  

end
