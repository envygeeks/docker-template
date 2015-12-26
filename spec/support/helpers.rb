# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module RSpec
  module Helpers
    extend self

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

    #

    module ClassMethods
      def include_contexts(*contexts)
        contexts.each do |val|
          include_context val
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.extend  RSpec::Helpers::ClassMethods
  config.include RSpec::Helpers
end
