require "spec_helper"

describe "Version" do
  subject { RSpec::Sidekiq::VERSION }

  expect_it { to eq("1.0.0") }
end