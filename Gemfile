# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

source "https://rubygems.org"
gem "rake", :require => false
gemspec

group :test do
  gem "rspec", :require => false
  gem "memory_profiler", :require => false
  gem "luna-rspec-formatters", :require => false
  gem "codeclimate-test-reporter", :require => false
  gem "rubocop", :github => "bbatsov/rubocop", :branch => :master, :require => false
  gem "luna-rubocop-formatters", :require => false
  gem "benchmark-ips", :require => false
  gem "rspec-helpers", :require => false
  gem "cucumber", :require => false
end

group :development do
  unless ENV["CI"]
    gem "pry", :require => false
    gem "msgpack", {
      :require => false
    }
  end
end
