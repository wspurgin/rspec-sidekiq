# RSpec for Sidekiq [![Build Status][travis_ci_build_status]][travis_ci][![Dependency Status][gemnasium_dependency_status]][gemnasium]
*Simple testing of Sidekiq jobs via a collection of matchers and common tasks*

[RubyGems][ruby_gems] | [Ruby Toolbox][ruby_toolbox] | [GitHub][github] | [Travis CI][travis_ci] | [Gemnasium][gemnasium] | [RubyDoc][ruby_doc]

## Installation
```
gem "rspec-sidekiq"
```

## Matchers
```ruby
be_processed_in
be_retryable
be_unique
have_enqueued_jobs
```

[ruby_gems]: http://rubygems.org/gems/rspec-sidekiq
[ruby_toolbox]: http://www.ruby-toolbox.com/projects/rspec-sidekiq
[github]: http://github.com/philostler/rspec-sidekiq
[travis_ci]: http://travis-ci.org/philostler/rspec-sidekiq
[travis_ci_build_status]: https://secure.travis-ci.org/philostler/rspec-sidekiq.png
[gemnasium]: https://gemnasium.com/philostler/rspec-sidekiq
[gemnasium_dependency_status]: https://gemnasium.com/philostler/rspec-sidekiq.png
[ruby_doc]: http://rubydoc.info/github/philostler/rspec-sidekiq/master/frames