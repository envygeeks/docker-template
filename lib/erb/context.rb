# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "erb"
class ERB
  class Context

    # --
    # Wraps any data you wish to send to ERB limiting it's context access.
    # @param [Hash] vars the variables you wish to set
    # --
    def initialize(vars)
      vars.each do |key, val|
        instance_variable_set("@#{key}", val)
      end
    end

    # --
    # Returns the binding so that we can ship it off and give it to ERB.
    # --
    def _binding
      return binding
    end
  end
end
