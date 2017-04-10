require 'spec_helper'

RSpec.describe RSpec::Sidekiq::VERSION do
  it { is_expected.to eq('3.0.1') }
end
