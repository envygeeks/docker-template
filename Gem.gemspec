# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))
require "docker/template/version"

Gem::Specification.new do |spec|
  spec.authors = ["Jordon Bedwell"]
  spec.executables << "docker-template"
  spec.version = Docker::Template::VERSION
  spec.description = "Build and template awesome Docker images a variety of ways."
  spec.files = %W(Rakefile Gemfile README.md LICENSE) + Dir["{lib,bin,templates}/**/*"]
  spec.summary = "Build and template Docker images a variety of ways."
  spec.homepage = "http://github.com/envygeeks/docker-template/"
  spec.required_ruby_version = ">= 2.3.0"
  spec.email = ["jordon@envygeeks.io"]
  spec.require_paths = ["lib"]
  spec.name = "docker-template"
  spec.license = "MIT"
  spec.has_rdoc = false
  spec.bindir = "bin"

  spec.add_runtime_dependency("thor", "~> 0.19")
  spec.add_runtime_dependency("docker-api", "~> 1.28")
  spec.add_runtime_dependency("activesupport", "~> 4.2")
  spec.add_runtime_dependency("simple-ansi", "~> 1.0")
  spec.add_runtime_dependency("pathutil", "~> 0.7")
  spec.add_runtime_dependency("extras", "~> 0.1")
  spec.add_runtime_dependency("json", "~> 1.8")
end
