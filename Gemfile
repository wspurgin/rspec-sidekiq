source 'https://rubygems.org'

%w[rspec rspec-core rspec-expectations rspec-mocks rspec-support].each do |lib|
  gem lib, :git => "git://github.com/rspec/#{lib}.git", :branch => 'master'
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'psych'
  gem 'rubinius-developer_tools'
end

gemspec
