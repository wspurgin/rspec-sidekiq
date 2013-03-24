require "spec_helper"

describe "Version" do
  subject { RSpec::Sidekiq::VERSION }

  expect_it { to eq("0.1.0") }
end