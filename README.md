# RSpec for Sidekiq [![RubyGems][gem_version_badge]][ruby_gems] [![Code Climate][code_climate_badge]][code_climate] [![Travis CI][travis_ci_badge]][travis_ci] [![Gemnasium][gemnasium_badge]][gemnasium]
*Simple testing of Sidekiq jobs via a collection of matchers and common tasks*

[RubyGems][ruby_gems] | [Code Climate][code_climate] | [GitHub][github] | [Travis CI][travis_ci] | [Gemnasium][gemnasium] | [RubyDoc][ruby_doc] | [Ruby Toolbox][ruby_toolbox]

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
* [have_enqueued_job](#have_enqueued_job)
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
# ...or alternatively specifiy the number of times it should be retried
it { should be_retryable 5 } } # one liner
expect(AwesomeJob).to be_retryable 5 # new expect syntax
```

### be_unique (Only available when using [sidekiq-middleware](https://github.com/krasnoukhov/sidekiq-middleware))
*Describes if the job should be unique within it's queue*
```ruby
it { should be_unique } } # one liner
expect(AwesomeJob).to be_unique # new expect syntax
```

### have_enqueued_job
*Evaluates that there is an enqueued job with the specified arguments*
```ruby
expect(AwesomeJob).to have_enqueued_job("Awesome", true) # new expect syntax
```

### have_enqueued_jobs
*Evaluates the number of enqueued jobs for a specified job class*
```ruby
expect(AwesomeJob).to have_enqueued_jobs(1) # new expect syntax
# ...but you could just use
expect(AwesomeJob).to have(1).jobs
# ...or even
expect(AwesomeJob).to have(1).enqueued.jobs
```

## Testing
```bundle exec rspec spec```

## Contribute
Yes do it! If there's a feature missing that you'd love them get in on the action!

Issues/Pull Requests/Comments bring them on...

[code_climate]: https://codeclimate.com/github/philostler/rspec-sidekiq
[code_climate_badge]: https://codeclimate.com/github/philostler/rspec-sidekiq.png
[gem_version_badge]: https://badge.fury.io/rb/rspec-sidekiq.png
[gemnasium]: https://gemnasium.com/philostler/rspec-sidekiq
[gemnasium_badge]: https://gemnasium.com/philostler/rspec-sidekiq.png
[github]: http://github.com/philostler/rspec-sidekiq
[ruby_doc]: http://rubydoc.info/github/philostler/rspec-sidekiq/master/frames
[ruby_gems]: http://rubygems.org/gems/rspec-sidekiq
[ruby_toolbox]: http://www.ruby-toolbox.com/projects/rspec-sidekiq
[travis_ci]: http://travis-ci.org/philostler/rspec-sidekiq
[travis_ci_badge]: https://secure.travis-ci.org/philostler/rspec-sidekiq.png