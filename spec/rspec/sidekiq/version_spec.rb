require "spec_helper"

describe RSpec::Sidekiq::VERSION do
  expect_it { to eq("1.0.0") }
end