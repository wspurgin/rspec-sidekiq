class TestWorker
  include Sidekiq::Worker

  sidekiq_options queue: :data, retry: 5, unique: true

  def perform
  end
end
