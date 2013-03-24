# RSpec for Sidekiq [![Build Status][travis_ci_build_status]][travis_ci][![Dependency Status][gemnasium_dependency_status]][gemnasium]
*Simple testing of Sidekiq jobs via a collection of matchers and common tasks*

[RubyGems][ruby_gems] | [GitHub][github] | [Travis CI][travis_ci] | [Gemnasium][gemnasium] | [RubyDoc][ruby_doc] | [Ruby Toolbox][ruby_toolbox] 

## Installation
```
gem "rspec-sidekiq"
```
There is no need to ```require "sidekiq/testing"``` when using rspec-sidekiq

## Configuration
```ruby
RSpec::Sidekiq.configure do |config|
  # Clears all job queues before each example
  config.clear_all_enqueued_jobs = false # default => true
end
```

## Matchers
* [be_processed_in](#be_processed_in)
* [be_retryable](#be_retryable)
* [be_unique](#be_unique)
* [have_enqueued_jobs](#have_enqueued_jobs)

### be_processed_in
*Describes the queue that the job should be processed in*
```ruby
it { should be_processed_in :download } } # one liner
expect(AwesomeJob).to be_processed_in :download # new expect syntax
```

### be_retryable
*Describes if the job retries when there is a failure in it's execution*
```ruby
it { should be_retryable true } } # one liner
expect(AwesomeJob).to be_retryable true # new expect syntax
```

### be_unique (Only available when using [sidekiq-middleware](https://github.com/krasnoukhov/sidekiq-middleware))
*Describes if the job should be unique within it's queue*
```ruby
it { should be_unique } } # one liner
expect(AwesomeJob).to be_unique # new expect syntax
```

### have_enqueued_jobs
*Evaluates the number of enqueued jobs for a specified job*
```ruby
expect(AwesomeJob).to have_enqueued_jobs(1) # new expect syntax
```

[ruby_gems]: http://rubygems.org/gems/rspec-sidekiq
[ruby_toolbox]: http://www.ruby-toolbox.com/projects/rspec-sidekiq
[github]: http://github.com/philostler/rspec-sidekiq
[travis_ci]: http://travis-ci.org/philostler/rspec-sidekiq
[travis_ci_build_status]: https://secure.travis-ci.org/philostler/rspec-sidekiq.png
[gemnasium]: https://gemnasium.com/philostler/rspec-sidekiq
[gemnasium_dependency_status]: https://gemnasium.com/philostler/rspec-sidekiq.png
[ruby_doc]: http://rubydoc.info/github/philostler/rspec-sidekiq/master/frames