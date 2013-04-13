require "coveralls"
require "sidekiq"
require "rspec-sidekiq"

Coveralls.wear!

RSpec.configure do |config|
  config.alias_example_to :expect_it

  config.expect_with :rspec do |config|
    config.syntax = :expect
  end
end

RSpec::Core::MemoizedHelpers.module_eval do
  alias to should
  alias to_not should_not
end