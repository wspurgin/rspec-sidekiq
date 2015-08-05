class TestJob < ActiveJob::Base
  queue_as :mailers

  def perform
  end
end
