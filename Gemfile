# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

source "https://rubygems.org"
gem "rake", :require => false
gemspec

group :test do
  gem "luna-rspec-formatters", :require => false
  gem "codeclimate-test-reporter", :require => false
  gem "rspec-helpers", :require => false
  gem "rspec", :require => false
end

group :development do
  unless ENV["CI"]
    gem "pry", :require => false
    gem "rubocop", {
      :github => "bbatsov/rubocop",
      :branch => :master, :require => false
    }
  end
end
