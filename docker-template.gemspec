# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

$:.unshift(File.expand_path("../lib", __FILE__))
require "docker/template/version"

Gem::Specification.new do |spec|
  spec.authors = ["Jordon Bedwell"]
  spec.executables << 'docker-template'
  spec.version = Docker::Template::VERSION
  spec.files = %W(Rakefile Gemfile README.md LICENSE) + Dir["{lib,bin}/**/*"]
  spec.description = "Build and template awesome Docker images a variety of ways."
  spec.summary = "Build and template Docker images a variety of ways."
  spec.homepage = "http://github.com/envygeeks/docker-template/"
  spec.email = ["jordon@envygeeks.io"]
  spec.require_paths = ["lib"]
  spec.name = "docker-template"
  spec.license = "MIT"
  spec.has_rdoc = false
  spec.bindir = "bin"

  spec.add_runtime_dependency("json", "~> 1.8")
  spec.add_runtime_dependency("docker-api", "~> 1.23")
  spec.add_development_dependency("luna-rspec-formatters", "~> 3.4")
  spec.add_development_dependency("envygeeks-coveralls", "~> 1.1")
  spec.add_development_dependency("rspec", "~> 3.4")
end
