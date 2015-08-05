class TestResource
  include GlobalID::Identification

  attr_reader :global_id

  def initialize
    @global_id = GlobalID.create(self, { app: 'rspec-sidekiq' })
  end

  def self.find(id)
  end

  def id
    rand(36**10).to_s 36
  end
end
