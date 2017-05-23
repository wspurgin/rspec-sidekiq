require 'simplecov'
require 'coveralls'

require 'sidekiq'
require 'rspec-sidekiq'

require 'active_job'
require 'action_mailer'
require 'active_record'

require_relative 'support/init'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.start

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.include RSpec::Sidekiq::Spec::Support::Factories
end

ActiveJob::Base.queue_adapter = :sidekiq

if Gem::Dependency.new('sidekiq', '>= 5.0.0').matching_specs.any?
  ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)
  Sidekiq::Extensions.enable_delay!
end
