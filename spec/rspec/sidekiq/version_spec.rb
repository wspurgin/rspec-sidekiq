require 'spec_helper'

RSpec.describe RSpec::Sidekiq::VERSION do
  it { is_expected.to eq('2.0.0') }
end
