# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

class String
  module Patches
    def to_a
      split " "
    end
  end

  prepend Patches
end
