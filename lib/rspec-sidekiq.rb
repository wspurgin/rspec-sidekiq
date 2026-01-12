# frozen_string_literal: true

require 'forwardable'

require 'sidekiq'
require 'sidekiq/testing'

require_relative 'rspec/sidekiq/batch'
require_relative 'rspec/sidekiq/configuration'
require_relative 'rspec/sidekiq/helpers'
require_relative 'rspec/sidekiq/matchers'
require_relative 'rspec/sidekiq/named_queues'
require_relative 'rspec/sidekiq/sidekiq'
