class TestWorker
  include Sidekiq::Worker

  sidekiq_options queue: :data

  def perform
  end
end