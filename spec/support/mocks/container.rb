# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Mocks
  class Container
    attr_reader :struct
    def initialize
      @mocked = [
        :delete,
        :streaming_logs,
        :attach,
        :stop
      ]
    end

    #

    def json
      {
        "State" => {
          "ExitCode" => 0
        }
      }
    end

    #

    def start(*_)
      self
    end

    #

    def method_missing(method, *args, &block)
      if @mocked.include?(method)
        nil else super
      end
    end
  end
end
