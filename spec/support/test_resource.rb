class TestResource
  include GlobalID::Identification

  def self.find(id)
  end

  def id
    @id ||= rand(36**10).to_s 36
  end
end
