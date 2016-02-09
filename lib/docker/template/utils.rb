# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Utils
      module_function

      # ----------------------------------------------------------------------
      # Split an array or if given an array return the array.
      # ----------------------------------------------------------------------

      def split(obj)
        return obj if obj.is_a?(Array)
        return [ ] if obj.nil?
        obj.split(
          /\s+/
        )
      end

      # ----------------------------------------------------------------------
      # Checks to see if any of the given keys exist, not just one.
      # ----------------------------------------------------------------------

      def any_keys?(object, *keys)
        list = object.is_a?(Array) ? object : object.keys
        keys.map(&list.method(:include?)).any? do |val|
          val == true
        end
      end

      # ----------------------------------------------------------------------
      # Merge two hashes merging sub-hashes recursively along the way.
      # ----------------------------------------------------------------------

      def deep_merge(oldh, newh)
        oldh.merge(newh) do |_, oval, nval|
          if !oval.is_a?(Hash) || !nval.is_a?(Hash)
            then nval else deep_merge(
              oval, nval
            )
          end
        end
      end
    end
  end
end
