# frozen_string_literal: true

require 'forwardable'

require 'sidekiq'
if Gem::Version.new(Sidekiq::VERSION) >= Gem::Version.new('8.1.1')
  Sidekiq.testing!(:fake)
else
  require 'sidekiq/testing'
end

require_relative 'rspec/sidekiq/batch'
require_relative 'rspec/sidekiq/configuration'
require_relative 'rspec/sidekiq/helpers'
require_relative 'rspec/sidekiq/matchers'
require_relative 'rspec/sidekiq/named_queues'
require_relative 'rspec/sidekiq/sidekiq'
