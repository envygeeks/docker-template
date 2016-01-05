# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

class Object
  module Patches
    def to_pathname
      Object::Pathname.new(self)
    end
  end

  prepend Patches
end
