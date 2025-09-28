[![Gem Version](https://badge.fury.io/rb/rspec-sidekiq.svg)](https://badge.fury.io/rb/rspec-sidekiq)
[![Github Actions CI][github_actions_badge]][github_actions]

Simple testing of Sidekiq jobs via a collection of matchers and helpers.

[Jump to Matchers »](#matchers) | [Jump to Helpers »](#helpers)

## Installation

```ruby
# Gemfile
group :test do
  gem 'rspec-sidekiq'
end
```

rspec-sidekiq requires `sidekiq/testing` by default so there is no need to include the line `require "sidekiq/testing"` inside your `spec_helper.rb`.

> [!IMPORTANT]
> This has the effect of not pushing enqueued jobs to Redis but to a `job` array to enable testing ([see the FAQ & Troubleshooting Wiki page][rspec_sidekiq_wiki_faq_&_troubleshooting]). Thus, only include `gem "rspec-sidekiq"` in environments where this behaviour is required, such as the `test` group.*

## Configuration

If you wish to modify the default behaviour, add the following to your `spec_helper.rb` file

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

* [`enqueue_sidekiq_job`](#enqueue_sidekiq_job)
* [`have_enqueued_sidekiq_job`](#have_enqueued_sidekiq_job)
* [`be_processed_in`](#be_processed_in)
* [`be_retryable`](#be_retryable)
* [`save_backtrace`](#save_backtrace)
* [`be_unique`](#be_unique)
* [`be_expired_in`](#be_expired_in)
* [`be_delayed` (_deprecated_)](#be_delayed)

### `enqueue_sidekiq_job`

*Describes that the block should enqueue a job*. Optionally specify the
specific job class, arguments, timing, and other context

```ruby
# Basic
expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job

# A specific job class
expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job(AwesomeJob)

# with specific arguments
expect { AwesomeJob.perform_async "Awesome!" }.to enqueue_sidekiq_job.with("Awesome!")

# On a specific queue
expect { AwesomeJob.set(queue: "high").perform_async }.to enqueue_sidekiq_job.on("high")

# At a specific datetime
specific_time = 1.hour.from_now
expect { AwesomeJob.perform_at(specific_time) }.to enqueue_sidekiq_job.at(specific_time)

# In a specific interval (be mindful of freezing or managing time here)
freeze_time do
  expect { AwesomeJob.perform_in(1.hour) }.to enqueue_sidekiq_job.in(1.hour)
end

# A specific number of times

expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job.never
expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job.exactly(0)
expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job.exactly(0).time
expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job.once
expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job.exactly(1).time
expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job.exactly(:once)
expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job.at_least(1).time
expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job.at_least(:once)
expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job.at_most(2).times
expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job.at_most(:twice)
expect { AwesomeJob.perform_async }.to enqueue_sidekiq_job.at_most(:thrice)

# With specific context:
# Useful for testing anything `set` on the job, including
# overrides to things like `retry`
expect {
  AwesomeJob.set(trace_id: "something").perform_async
}.to enqueue_sidekiq_job.with_context(trace_id: anything)

expect {
  AwesomeJob.set(retry: 5).perform_async
}.to enqueue_sidekiq_job.with_context(retry: 5)

# Combine and chain them as desired
expect { AwesomeJob.perform_at(specific_time, "Awesome!") }.to(
  enqueue_sidekiq_job(AwesomeJob)
  .with("Awesome!")
  .on("default")
  .at(specific_time)
)

# Also composable
expect do
  AwesomeJob.perform_async
  OtherJob.perform_async
end.to enqueue_sidekiq_job(AwesomeJob).and enqueue_sidekiq_job(OtherJob)
```

### `have_enqueued_sidekiq_job`

Describes that there should be an enqueued job (with the specified arguments):

```ruby
AwesomeJob.perform_async 'Awesome', true
# test with...
expect(AwesomeJob).to have_enqueued_sidekiq_job
expect(AwesomeJob).to have_enqueued_sidekiq_job('Awesome', true)
```

You can use the built-in RSpec args matchers too:

```ruby
AwesomeJob.perform_async({"something" => "Awesome", "extra" => "stuff"})

# using built-in matchers from rspec-mocks:
expect(AwesomeJob).to have_enqueued_sidekiq_job(hash_including("something" => "Awesome"))
expect(AwesomeJob).to have_enqueued_sidekiq_job(any_args)
expect(AwesomeJob).to have_enqueued_sidekiq_job(hash_excluding("bad_stuff" => anything))

# composable as well
expect(AwesomeJob).to have_enqueued_sidekiq_job(any_args).and have_enqueued_sidekiq_job(hash_including("something" => "Awesome"))
```

You can specify the number of jobs enqueued:

```ruby
expect(AwesomeJob).to have_enqueued_sidekiq_job.once
expect(AwesomeJob).to have_enqueued_sidekiq_job.exactly(1).time
expect(AwesomeJob).to have_enqueued_sidekiq_job.exactly(:once)
expect(AwesomeJob).to have_enqueued_sidekiq_job.at_least(1).time
expect(AwesomeJob).to have_enqueued_sidekiq_job.at_least(:once)
expect(AwesomeJob).to have_enqueued_sidekiq_job.at_most(2).times
expect(AwesomeJob).to have_enqueued_sidekiq_job.at_most(:twice)
expect(AwesomeJob).to have_enqueued_sidekiq_job.at_most(:thrice)
```

Likewise, specify what should be in the context:

```ruby
AwesomeJob.set(trace_id: "something").perform_async

expect(AwesomeJob).to have_enqueued_sidekiq_job.with_context(trace_id: anything)
```

#### Testing scheduled jobs

*Use chainable matchers `#at`, `#in` and `#immediately`*

```ruby
time = 5.minutes.from_now
AwesomeJob.perform_at time, 'Awesome', true
# test with...
expect(AwesomeJob).to have_enqueued_sidekiq_job('Awesome', true).at(time)
```

```ruby
AwesomeJob.perform_in 5.minutes, 'Awesome', true
# test with...
expect(AwesomeJob).to have_enqueued_sidekiq_job('Awesome', true).in(5.minutes)
```

```ruby
# Job scheduled for a date in the past are enqueued immediately.
AwesomeJob.perform_later 5.minutes.ago, 'Awesome', true # equivalent to: AwesomeJob.perform_async 'Awesome', true
# test with...
expect(AwesomeJob).to have_enqueued_sidekiq_job('Awesome', true).immediately
```

#### Testing queue set for job

Use the chainable `#on` matcher

```ruby
class AwesomeJob
  include Sidekiq::Job

  sidekiq_options queue: :low
end

AwesomeJob.perform_async("a little awesome")

# test with..
expect(AwesomeJob).to have_enqueued_sidekiq_job("a little awesome").on("low")

# Setting the queue when enqueuing
AwesomeJob.set(queue: "high").perform_async("Very Awesome!")

expect(AwesomeJob).to have_enqueued_sidekiq_job("Very Awesome!").on("high")
```

#### Testing ActiveMailer jobs

```ruby
user = User.first
AwesomeActionMailer.invite(user, true).deliver_later

expect(Sidekiq::Worker).to have_enqueued_sidekiq_job(
  "AwesomeActionMailer",
  "invite",
  "deliver_now",
  user,
  true
)
```

### `be_processed_in`

*Describes the queue that a job should be processed in*

```ruby
sidekiq_options queue: :download
# test with...
expect(AwesomeJob).to be_processed_in :download # or
it { is_expected.to be_processed_in :download }
```

### `be_retryable`

*Describes if a job should retry when there is a failure in its execution*

Note: this only tests against the `retry` option in the job's Sidekiq options.
To test an enqueued job's retry, i.e. `AwesomeJob.set(retry: 5)`, use
`with_context`

```ruby
sidekiq_options retry: 5
# test with...
expect(AwesomeJob).to be_retryable true # or
it { is_expected.to be_retryable true }
# ...or alternatively specify the number of times it should be retried
expect(AwesomeJob).to be_retryable 5 # or
it { is_expected.to be_retryable 5 }
# ...or when it should not retry
expect(AwesomeJob).to be_retryable false # or
it { is_expected.to be_retryable false }
```

### `save_backtrace`

*Describes if a job should save the error backtrace when there is a failure in its execution*

```ruby
sidekiq_options backtrace: 5
# test with...
expect(AwesomeJob).to save_backtrace # or
it { is_expected.to save_backtrace }
# ...or alternatively specify the number of lines that should be saved
expect(AwesomeJob).to save_backtrace 5 # or
it { is_expected.to save_backtrace 5 }
# ...or when it should not save the backtrace
expect(AwesomeJob).to_not save_backtrace # or
expect(AwesomeJob).to save_backtrace false # or
it { is_expected.to_not save_backtrace } # or
it { is_expected.to save_backtrace false }
```

### `be_unique`

> [!CAUTION]
> This is intended to for Sidekiq Enterprise unique job implementation.
> There is _limited_ support for Sidekiq Unique Jobs, but compatibility is not
> guaranteed.

*Describes when a job should be unique within its queue*

```ruby
sidekiq_options unique_for: 1.hour
# test with...
expect(AwesomeJob).to be_unique
it { is_expected.to be_unique }

# specify a specific interval
sidekiq_options unique_for: 1.hour
it { is_expected.to be_unique.for(1.hour) }
```

#### `until` sub-matcher

> [!CAUTION]
> This sub-matcher only works for Sidekiq Enterprise

```ruby
sidekiq_options unique_for: 1.hour, unique_until: :start
it { is_expected.to be_unique.until(:start) }
```

### `be_expired_in`

*Describes when a job should expire*

```ruby
sidekiq_options expires_in: 1.hour
# test with...
it { is_expected.to be_expired_in 1.hour }
it { is_expected.to_not be_expired_in 2.hours }
```

### `be_delayed`

**This matcher is deprecated**. Use of it with Sidekiq 7+ will raise an error.
Sidekiq 7 [dropped Delayed
Extensions](https://github.com/sidekiq/sidekiq/issues/5076).

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

#Rails Mailer
MyMailer.delay.some_mail
expect(MyMailer.instance_method :some_mail).to be_delayed
```

## Example matcher usage

```ruby
require 'spec_helper'

describe AwesomeJob do
  it { is_expected.to be_processed_in :my_queue }
  it { is_expected.to be_retryable 5 }
  it { is_expected.to be_unique }
  it { is_expected.to be_expired_in 1.hour }

  it 'enqueues another awesome job' do
    subject.perform

    expect(AnotherAwesomeJob).to have_enqueued_sidekiq_job('Awesome', true)
  end
end
```

## Helpers

* [Batches (Sidekiq Pro) _experimental_](#batches)
* [`within_sidekiq_retries_exhausted_block`](#within_sidekiq_retries_exhausted_block)

### Batches

If you are using Sidekiq Batches ([Sidekiq Pro feature][sidekiq_wiki_batches]),
You can *opt-in* with `stub_batches` to make `rspec-sidekiq` mock the
implementation (using a NullObject pattern). This enables testing without a
Redis instance. Mocha and RSpec stubbing is supported here.

> [!CAUTION]
> Opting-in to this feature, while allowing you to test without
> having Redis, _does not_ provide the exact API that `Sidekiq::Batch` does. As
> such it can cause surprises.

```ruby
RSpec.describe "Using mocked batches", stub_batches: true do
  it "uses mocked batches" do
    batch = Sidekiq::Batch.new
    batch.jobs do
      SomeJob.perform_async 123
    end

    expect(SomeJob).to have_enqueued_sidekiq_job

    # Caution, the NullObject pattern means that the mocked Batch implementation
    # responds to anything... even if it's not on the true `Sidekiq::Batch` API
    # For example, the following fails
    expect { batch.foobar! }.to raise_error(NoMethodError)
  end
end
```

### within_sidekiq_retries_exhausted_block

```ruby
sidekiq_retries_exhausted do |msg|
  bar('hello')
end
# test with...
FooClass.within_sidekiq_retries_exhausted_block {
  expect(FooClass).to receive(:bar).with('hello')
}
```

## Testing

```
bundle exec rspec
```

## Maintainers

* [@wspurgin]
* [@ydah]

### Alumni

* [@packrat386]
* [@philostler]

## Contribute

Please do! If there's a feature missing that you'd love to see then get in on the action!

Issues/Pull Requests/Comments all welcome...

[@packrat386]: https://github.com/packrat386
[@philostler]: https://github.com/philostler
[@wspurgin]: https://github.com/wspurgin
[@ydah]: https://github.com/ydah
[github_actions]: https://github.com/wspurgin/rspec-sidekiq/actions
[github_actions_badge]: https://github.com/wspurgin/rspec-sidekiq/actions/workflows/main.yml/badge.svg
[rspec_sidekiq_wiki_faq_&_troubleshooting]: https://github.com/wspurgin/rspec-sidekiq/wiki/FAQ-&-Troubleshooting
[sidekiq_wiki_batches]: https://github.com/sidekiq/sidekiq/wiki/Batches
[sidekiq_wiki_delayed_extensions]: https://github.com/sidekiq/sidekiq/wiki/Delayed-Extensions
