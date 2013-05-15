class TestWorkerDefaults
  include Sidekiq::Worker

  def perform
  end
end