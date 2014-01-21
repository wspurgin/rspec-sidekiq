# RSpec for Sidekiq

[![RubyGems][gem_version_badge]][ruby_gems]
[![Code Climate][code_climate_badge]][code_climate]
[![Travis CI][travis_ci_badge]][travis_ci]
[![Coveralls][coveralls_badge]][coveralls]
[![Gemnasium][gemnasium_badge]][gemnasium]
[![coderwall][coderwall_badge]][coderwall]

*Simple testing of Sidekiq jobs via a collection of matchers and helpers*

[RubyGems][ruby_gems] |
[Code Climate][code_climate] |
[GitHub][github] |
[Travis CI][travis_ci] |
[Coveralls][coveralls] |
[Gemnasium][gemnasium] |
[RubyDoc][ruby_doc] |
[Ruby Toolbox][ruby_toolbox]

[Jump to Matchers &raquo;](#matchers) | [Jump to Helpers &raquo;](#helpers)

## Installation
```ruby
# Gemfile
group :test do
  gem "rspec-sidekiq"
end
```
rspec-sidekiq requires ```sidekiq/testing``` by default so there is no need to include the line ```require "sidekiq/testing"``` inside your ```spec_helper.rb```.

*IMPORTANT! This has the effect of not pushing enqueued jobs to Redis but to a ```job``` array to enable testing ([see the FAQ & Troubleshooting Wiki page][rspec_sidekiq_wiki_faq_&_troubleshooting]). Thus, only include ```gem "rspec-sidekiq"``` in environments where this behaviour is required, such as the ```test``` group.*

## Configuration
If you wish to modify the default behaviour, add the following to your ```spec_helper.rb``` file
```ruby
RSpec::Sidekiq.configure do |config|
  # Clears all job queues before each example
  config.clear_all_enqueued_jobs = true # default => true

  # Whether to use terminal colours when outputting messages
  config.enable_terminal_colours = true # default => true

  # Warn when jobs are not enqueued to Redis but to a job array
  config.warn_when_jobs_not_processed_by_sidekiq = true # default => true
end
```

## Matchers
* [be_delayed](#be_delayed)
* [be_processed_in](#be_processed_in)
* [be_retryable](#be_retryable)
* [be_unique](#be_unique)
* [have_enqueued_job](#have_enqueued_job)
* ~~[have_enqueued_jobs](#have_enqueued_jobs)~~

### be_delayed
*Describes a method that should be invoked asynchronously (See [Sidekiq Delayed Extensions][sidekiq_wiki_delayed_extensions])*
```ruby
Object.delay.is_nil? # delay
expect(Object.method :is_nil?).to be_delayed
Object.delay.is_a? Object # delay with argument
expect(Object.method :is_a?).to be_delayed(Object)

Object.delay_for(1.hour).is_nil? # delay for
expect(Object.method :is_nil?).to be_delayed.for 1.hour
Object.delay_for(1.hour).is_a? Object # delay for with argument
expect(Object.method :is_a?).to be_delayed(Object).for 1.hour

Object.delay_until(1.hour.from_now).is_nil? # delay until
expect(Object.method :is_nil?).to be_delayed.until 1.hour.from_now
Object.delay_until(1.hour.from_now).is_a? Object # delay until with argument
expect(Object.method :is_a?).to be_delayed(Object).until 1.hour.from_now
```

### be_processed_in
*Describes the queue that a job should be processed in*
```ruby
sidekiq_options queue: :download
# test with...
expect(AwesomeJob).to be_processed_in :download # or
it { should be_processed_in :download }
```

### be_retryable
*Describes if a job should retry when there is a failure in it's execution*
```ruby
sidekiq_options retry: 5
# test with...
expect(AwesomeJob).to be_retryable true # or
it { should be_retryable true }
# ...or alternatively specifiy the number of times it should be retried
expect(AwesomeJob).to be_retryable 5 # or
it { should be_retryable 5 }
# ...or when it should not retry
expect(AwesomeJob).to be_retryable false # or
it { should be_retryable false }
```

### be_unique
*Describes when a job should be unique within it's queue*
```ruby
sidekiq_options unique: true
# test with...
expect(AwesomeJob).to be_unique
it { should be_unique }
```

### have_enqueued_job
*Describes that there should be an enqueued job with the specified arguments*
```ruby
Awesomejob.perform_async "Awesome", true
# test with...
expect(AwesomeJob).to have_enqueued_job("Awesome", true)
```

### ~~have_enqueued_jobs~~
*Removed. [See the FAQ & Troubleshooting Wiki page][rspec_sidekiq_wiki_faq_&_troubleshooting] for alternative and more information*

## Example matcher usage
```ruby
require "spec_helper"

describe AwesomeJob do
  it { should be_processed_in :my_queue }
  it { should be_retryable 5 }
  it { should be_unique }

  it "enqueues another awesome job" do
    subject.perform

    expect(AnotherAwesomeJob).to have_enqueued_job("Awesome", true)
  end
end
```

## Helpers
* [Batches](#batches)
* [within_sidekiq_retries_exhausted_block](#within_sidekiq_retries_exhausted_block)

### Batches
If you are using Sidekiq Batches ([Sidekiq Pro feature][sidekiq_wiki_batches]), rspec-sidekiq replaces the implementation (using the NullObject pattern) enabling testing without a Redis instance. Mocha and RSpec stubbing is supported here.

### within_sidekiq_retries_exhausted_block
```ruby
sidekiq_retries_exhausted do |msg|
  bar('hello')
end
# test with...
FooClass.within_sidekiq_retries_exhausted_block {
  expect(FooClass).to receive(:bar).with("hello")
}
```

## Testing
```bundle exec rspec spec```

## Contribute
Please do! If there's a feature missing that you'd love to see then get in on the action!

Issues/Pull Requests/Comments all welcome...

[code_climate]: https://codeclimate.com/github/philostler/rspec-sidekiq
[code_climate_badge]: https://codeclimate.com/github/philostler/rspec-sidekiq.png
[coderwall]: https://coderwall.com/philostler
[coderwall_badge]: https://api.coderwall.com/philostler/endorsecount.png
[coveralls]: https://coveralls.io/r/philostler/rspec-sidekiq
[coveralls_badge]: https://coveralls.io/repos/philostler/rspec-sidekiq/badge.png?branch=master
[gem_version_badge]: https://badge.fury.io/rb/rspec-sidekiq.png
[gemnasium]: https://gemnasium.com/philostler/rspec-sidekiq
[gemnasium_badge]: https://gemnasium.com/philostler/rspec-sidekiq.png
[github]: http://github.com/philostler/rspec-sidekiq
[ruby_doc]: http://rubydoc.info/github/philostler/rspec-sidekiq/master/frames
[ruby_gems]: http://rubygems.org/gems/rspec-sidekiq
[ruby_toolbox]: http://www.ruby-toolbox.com/projects/rspec-sidekiq
[travis_ci]: http://travis-ci.org/philostler/rspec-sidekiq
[travis_ci_badge]: https://secure.travis-ci.org/philostler/rspec-sidekiq.png

[rspec_sidekiq_wiki_faq_&_troubleshooting]: https://github.com/philostler/rspec-sidekiq/wiki/FAQ-&-Troubleshooting
[sidekiq_wiki_batches]: https://github.com/mperham/sidekiq/wiki/Batches
[sidekiq_wiki_delayed_extensions]: https://github.com/mperham/sidekiq/wiki/Delayed-Extensions
