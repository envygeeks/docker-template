# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Hooks
      class Wrapper
        attr_reader :order, :name, :source
        def initialize(name, source, order = 99)
          @order = order
          @source = source
          @name = name
        end
      end
    end
  end
end
