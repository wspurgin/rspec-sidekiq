require 'spec_helper'

describe RSpec::Sidekiq::VERSION do
  expect_it { to eq('2.0.0.beta') }
end
