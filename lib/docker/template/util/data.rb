# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Util

      # Provides a way to encapsulate data for ERB processing so that we
      # don't get full unfettered access to the entire binding from within
      # our ERB processing context.  Nobody wants that.

      class Data
        def initialize(vars)
          vars.each do |key, val|
            instance_variable_set("@#{key}", val)
          end
        end

        def _binding
          return binding
        end
      end
    end
  end
end
