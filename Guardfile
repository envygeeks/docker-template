# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "guard/rspec/dsl"
guard :rspec, :cmd => "bundle exec rspec -fLuna::RSpec::Formatters::Checks" do
  dsl  = Guard::RSpec::Dsl.new(self)
  watch(dsl.rspec.spec_files)
  dsl.watch_spec_files_for(
    dsl.ruby.lib_files
  )
end
