# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

class Object
  module Patches
    def to_pathname
      Pathutil.new(
        self
      )
    end
  end

  prepend Patches
end
