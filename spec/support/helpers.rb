# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module RSpec
  module Helpers
    Template = Docker::Template
    extend self

    def in_data(&block)
      old_root = Template.root
      old_repos_root = Template.repos_root
      root_path = Pathname.new(File.expand_path("../data", __dir__))
      repos_root_path = Pathname.new(root_path.join(Template.config["repos_dir"]))
      Template.instance_variable_set(:@repos_root, repos_root_path)
      Template.instance_variable_set(:@root, root_path)

      yield
    ensure
      Template.instance_variable_set(:@root, old_root)
      Template.instance_variable_set(:@repos_root, old_repos_root)
    end

    #

    def silence_io(capture: false, &block)
      old_stdout, $stdout = $stdout, (stdout = StringIO.new)
      old_stderr, $stderr = $stderr, (stderr = StringIO.new)

      if !capture
        yield
      else
        yield
        return {
          :stderr => stderr.string,
          :stdout => stdout.string
        }
      end
    ensure
      $stdout = old_stdout
      $stderr = old_stderr
    end

    #

    def capture_io(&block)
      silence_io(capture: true, &block)
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Helpers
end
