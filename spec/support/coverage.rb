# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

if ENV["CI"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter \
    .start

else
  require "simplecov"
  SimpleCov \
    .start
end
