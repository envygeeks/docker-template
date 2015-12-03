# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

$:.unshift(File.expand_path("../lib", __FILE__))
require "rspec/core/rake_task"
task :default => [:spec]
RSpec::Core::RakeTask.new :spec
task :test => :spec

task :build do
  exec "bundle", "exec", "bin/docker-template", *ARGV[
    1..-1
  ]
end

task :pry do
  sh "bundle", "exec", "pry", "-Ilib/", \
    "-rdocker/template"
end

task :analysis do
  sh "docker", "run", "--rm", "--env=CODE_PATH=#{Dir.pwd}", \
    "--volume=#{Dir.pwd}:/code", "--volume=/var/run/docker.sock:/var/run/docker.sock", \
    "--volume=/tmp/cc:/tmp/cc", "-it", \
    "codeclimate/codeclimate", "analyze"
end
