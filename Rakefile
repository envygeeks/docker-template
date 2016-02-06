# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))
require "rspec/core/rake_task"
require "simple/ansi"
require "open3"

task :default => [:spec]
RSpec::Core::RakeTask.new :spec
task :test => :spec

task :rubocop do
  sh "bundle", "exec", "rubocop", "-DE", "-r", "luna/rubocop/formatters/checks", \
    "-f", "Luna::RuboCop::Formatters::Checks"
end
