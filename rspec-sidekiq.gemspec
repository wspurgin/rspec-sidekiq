# frozen_string_literal: true

require File.expand_path("../lib/rspec/sidekiq/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rspec-sidekiq"
  s.version     = RSpec::Sidekiq::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Aidan Coyle", "Phil Ostler", "Will Spurgin"]
  s.homepage    = "http://github.com/wspurgin/rspec-sidekiq"
  s.summary     = "RSpec for Sidekiq"
  s.description = "Simple testing of Sidekiq jobs via a collection of matchers and helpers"
  s.license     = "MIT"

  s.metadata = {
    "changelog_uri" => "https://github.com/wspurgin/rspec-sidekiq/blob/main/CHANGES.md"
  }

  s.add_dependency "rspec-core", "~> 3.0"
  s.add_dependency "rspec-mocks", "~> 3.0"
  s.add_dependency "rspec-expectations", "~> 3.0"
  s.add_dependency "sidekiq", ">= 5", "< 9"

  s.add_development_dependency "pry"
  s.add_development_dependency "pry-doc"
  s.add_development_dependency "pry-nav"
  s.add_development_dependency "rspec"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "fuubar"
  s.add_development_dependency "activejob"
  s.add_development_dependency "actionmailer"
  s.add_development_dependency "activerecord"
  s.add_development_dependency "activemodel"
  s.add_development_dependency "activesupport"
  s.add_development_dependency "railties"

  s.files = `git ls-files -- lib/*`.split("\n")
  s.files += %w[CHANGES.md LICENSE README.md]
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.7"
end
