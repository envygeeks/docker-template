# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

source "https://rubygems.org"
gem "rake", :require => false
gemspec

group :test do
  gem "codeclimate-test-reporter", :require => false
end

group :development do
  gem "rspec", :require => false
  gem "guard-rspec", :require => false
  gem "benchmark-ips", :require => false
  gem "luna-rspec-formatters", :require => false
  gem "rubocop", :github => "bbatsov/rubocop", :branch => :master, :require => false
  gem "pry", :require => false
end
