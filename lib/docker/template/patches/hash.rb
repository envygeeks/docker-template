# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

class Hash
  module Patches

    # ------------------------------------------------------------------------
    # @example { :a => [1, 2, 3] }.to_env # => { "A" => "1 2 3" }
    # Converts a Hash into a hash of KEY => "val" and converts arrays into
    # into strings separated by a space so you can split or make into an Array
    # from inside of bash or anything you choose.
    # ------------------------------------------------------------------------

    def to_env
      each_with_object({}) do |(key, val), hsh|
        val = val.is_a?(Array) ? val.join(" ") : val.to_s
        key = key.to_s.upcase
        hsh[key] = val
      end
    end

    # ------------------------------------------------------------------------
    # Checks to see if any of the given keys exist, not just one.
    # ------------------------------------------------------------------------

    def any_keys?(*keys)
      keys.map(&method(:key?)).any? do |val|
        val == true
      end
    end

    # ------------------------------------------------------------------------
    # @example { :a => :hello } # => ["A=hello"]
    # Converts your hash with `to_env` and then makes it into an Array to be
    # passed directly into Docker for building.
    # ------------------------------------------------------------------------

    def to_env_ary
      to_env.each_with_object([]) do |(key, val), ary|
        ary << "#{key}=#{val}"
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
