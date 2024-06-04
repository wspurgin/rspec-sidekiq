# frozen_string_literal: true

class TestJob < ActiveJob::Base
  queue_as :mailers

  def perform
  end
end
