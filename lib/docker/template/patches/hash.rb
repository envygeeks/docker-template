# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

class Hash
  module Patches

    # ------------------------------------------------------------------------
    # Checks to see if any of the given keys exist, not just one.
    # ------------------------------------------------------------------------

    def any_keys?(*keys)
      keys.map(&method(:key?)).any? do |val|
        val == true
      end
    end

    # ------------------------------------------------------------------------
    # Merge two hashes merging sub-hashes recursively along the way.
    # ------------------------------------------------------------------------

    def deep_merge(newh)
      merge(newh) do |_, oval, nval|
        if oval.is_a?(self.class) && nval.is_a?(self.class)
          then oval.deep_merge(nval) else nval
        end
      end
    end

    # ------------------------------------------------------------------------

    def deep_merge!(newh)
      replace(deep_merge(
        newh
      ))
    end
  end

  prepend Patches
end
