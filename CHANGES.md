Unreleased
---
* Add `frozen_string_literal: true` (#220)

5.0.0
---
* [BREAKING] Make `have_enqueued_sidekiq_job()` match jobs with any arguments (same as `enqueue_sidekiq_job()` or `have_enqueued_sidekiq_job(any_args)`) (#215)
* Add support for expected number of jobs to both `enqueue_sidekiq_job` and `have_enqueued_sidekiq_job` (#219)

4.2.0
---
* Add warning about `have_enqueued_sidekiq_job` with no arguments (default will change in next major release) (#216, #217)

4.1.0
---
* Add Composable support to `enqueue_sidekiq_job` and
  `have_enqueued_sidekiq_job` (#211)
* Add `immediately` to specify that a job should be enqueued without any delay (#210)

4.0.2
---
* Explicitly require forwardable (#204)

4.0.1
---
* Restore the old normalizing expected args behavior with symbols (#205)
  * fixes an unintentional breaking change in 4.0.0

4.0.0
---
* [BREAKING] Dropped support for matching jobs on ActiveJob's private API args, (e.g. `_aj_globalid` and `_aj_ruby2_keywords`). `_aj_globalid` can be replaced with the object itself, e.g. `have_enqueued_sidekiq_job(user)`.
* [BREAKING] Dropped support for Ruby 2.6
* [BREAKING] Mocking Sidekiq::Batch is now _opt in_ (was opt-out) by default
* [BREAKING] Dropped the `have_enqueued_job` matcher (deprecated since v3)
* [BREAKING] Dropped support for Sidekiq <5
* [BREAKING] Dropped support for Rails 5
* Add support for Sidekiq 7 (#192)
* Add support for builtin argument matchers from rspec mocks for
  `have_enqueued_sidekiq_job` (#200)
* Add `#on` to `have_enqueued_sidekiq_job` to support testing queue at enqueue time (#197)
* Add `enqueue_sidekiq_job` for block-syntax style expectations
* Clarified `have_enqueued_sidekiq_job` error message to make it clear that the "actual arguments" list is an array of argument-lists across all enqueued jobs. (#195)
* Fix `in` and `at` evaluation to match Sidekiq (#194)
* Fix `be_delayed` argument matcher (#196)
* Fix argument matching ignoring order (#200)
* Fix `be_delayed` time math when using `delay_for` (#198)

3.1.0
---
* Add support for latest ruby and Rails 5 (coding-bunny #156)
* Support `Class#method` notation in batch callback (caalberts #155)
* Fix bug with time comparison in delayed jobs (geeosh #153 with help from col)
* remove usage of `Integer#blank?` (lanej #152)
* Add `NullBatch#description` (dsantosmerino #139)
* README updates (BenMusch #142, akihikodaki #141, wpolicarpo #160)

3.0.3
---
* Re-splat arguments for the have_enqueued_job alias (aprescott #136)

3.0.2
---
* README updates (nilsding #110, packrat386 #122)
* Ruby 2.4 support (packrat386 #119)
* Fixes for Sidekiq 5 deprecations (packrat #130 with help from trev)

3.0.1
---
* Remove implicit runtime dependency on ActiveSupport [aprescott#109]

3.0.0
---
* Use default arguments for NullStatus initialization [briansharon#111]
* Fix at and in chainable methods [wpolicarpo#109]
* Rely on all of RSpec in development [packrat386#101]
* Pass exception to within_sidekiq_retries_exhausted_block [packrat386#100]
* Add support for testing scheduled jobs [wpolicarpo#81]
* only depend on rspec-core [urkle#96]
* Add support for Sidekiq Enterprise [Geesu#82]
* Fix clash with rspec-rails [pavel-jurasek-bcgdv-com#95]

2.2.0
---
* Fix typo in README file [bradhaydon#87]
* Fix type in readme [graudeejs#80]
* Matchers::HaveEnqueuedJob breaks on jobs with Hash arguments [erikogan#77]
* have_enqueued_job fails if args includes a Hash bug [gPrado#74]

2.1.0
---
* ActiveJob support [tarzan#71]
* adding be expired in matcher [bernabas#72]
* Fixed testing failures with be_delayed matcher due to rename of `enqueued_at` to `created_at` in latest Sidekiq [philostler]
* Add support for NullBatch#on and NullStatus#failures to the null batch objects. [PacerPRO#64]
* Adding a save_backtrace matcher [webdestroya#61]
* Add flag to skip Batch stubs [paulfri#69]
* allow passing an instance method to be_delayed matcher [lastobelus#63]

2.0.0
---
* Get specs to green [petergoldstein#58]
* Update spec syntax in README. [futhr#60]

2.0.0.beta
---
* Add support for 3.0.0 [yelled3#47]
* Completely remove have_enqueued_jobs matcher [philostler#56]

1.1.0
---
* Added Support for RSpec 3 [TBAA#44]
* Fix gem build error ERROR: (Gem::InvalidSpecificationException) [mourad-ifeelgoods#42]
* Make sure sidekiq is required [mourad-ifeelgoods#43]
* attempt at fixing 'undefined method `configure' for RSpec:Module' [homanchou#51]
* Supports accessing the batch id [fabiokr#54]
* Pass message hash to retries_exhausted block [layervault#52]
* added support for unique scheduled worker matching [jkogara#55]

1.0.0
---
* Improve coverage and readability of README [philostler#26]
* Greatly increase test coverage [philostler#27]
* Refactor and greatly improve be_a_delayed_job matcher (now be_delayed) [philostler#24 & #25]
* Add implementation of status.total [matthargett & Kelly Felkins#32 & #39]
* Fix Rubinius build [petergoldstein#38]
* Remove have_enqueued_jobs matcher [philostler#37]
* Travis - Ruby 2.1.0, fix Rubinius build [petergoldstein#35]
* Prepare for RSpec 3.x [petergoldstein#34]
* Print warning when used in development mode [mperham & philostler#33]
* Add helper for testing retries exhausted block [Noreaster76#31]
* Allow to use [general matchers](https://www.relishapp.com/rspec/rspec-mocks/v/2-14/docs/argument-matchers/general-matchers) in have_enqueued_job [johanneswuerbach#30]
* Loosen RSpec dependency [philostler#23]
* Add delay extension matchers [sosaucily#22]
* Update coveralls development dependency to version 0.7.x [philostler]

0.5.1
---
* Allows Sidekiq::Batch support to work with Mocha as well RSpec stubbing [noiseunion#20]

0.5.0
---
* Adds stub support for Sidekiq::Batch [kmayer#17]

0.4.0
---
* Bug fix for matcher failure if sidekiq_options were defined as strings vs symbols [mhuffnagle#16 & philostler]
* Matcher tests (partial coverage) added [mhuffnagle#16 & philostler]

0.3.0
---
* Removed restriction on needing to use sidekiq-middleware with be_unique matcher [philostler#4]
* Ensure RSpec.configure is defined on loading rspec/sidekiq/matchers [centaure#3]

0.2.2
---
* Matcher ```be_retryable false``` not producing correct output description [philostler]

0.2.1
---
* Removed debug #puts [philostler]

0.2.0
---
* New #have_enqueued_job matcher [philostler]
* Improved #have_enqueued_jobs description [philostler]
* Minor documentation updates [philostler]

0.1.0
---
* Initial release [philostler]
