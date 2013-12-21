require "simplecov"
require "coveralls"

require "sidekiq"
require "rspec-sidekiq"

require_relative "support/init"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.start

RSpec.configure do |config|
  config.alias_example_to :expect_it

  config.expect_with :rspec do |config|
    config.syntax = :expect
  end

  config.include RSpec::Sidekiq::Spec::Support::Factories
end

RSpec::Core::MemoizedHelpers.module_eval do
  alias to should
  alias to_not should_not
end