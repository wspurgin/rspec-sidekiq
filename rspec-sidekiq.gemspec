require File.expand_path('../lib/rspec/sidekiq/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'rspec-sidekiq'
  s.version     = RSpec::Sidekiq::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = 'Phil Ostler'
  s.email       = 'github@philostler.com'
  s.homepage    = 'http://github.com/philostler/rspec-sidekiq'
  s.summary     = 'RSpec for Sidekiq'
  s.description = 'Simple testing of Sidekiq jobs via a collection of matchers and helpers'
  s.license     = 'MIT'

  s.add_dependency 'rspec-core', '~> 3.0', '>= 3.0.0'
  s.add_dependency 'sidekiq', '>= 2.4.0'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'fuubar'
  s.add_development_dependency 'activejob'
  s.add_development_dependency 'actionmailer'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'activemodel'
  s.add_development_dependency 'activesupport'


  s.files = Dir['.gitattributes'] +
            Dir['.gitignore'] +
            Dir['.rspec'] +
            Dir['.simplecov'] +
            Dir['.travis'] +
            Dir['CHANGES.md'] +
            Dir['Gemfile'] +
            Dir['LICENSE'] +
            Dir['README.md'] +
            Dir['rspec-sidekiq.gemspec'] +
            Dir['**/*.rb']
  s.require_paths = ['lib']
end
