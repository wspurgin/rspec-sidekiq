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
