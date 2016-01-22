# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Utils
      module Stringify
        extend self

        # --------------------------------------------------------------------

        ALLOWED_CLASSES = [TrueClass, FalseClass,
          String, Hash, Array, Set].freeze

        # --------------------------------------------------------------------
        # Stringify a hash and it' keys, unless it's an allowed value type.
        # @param [Hash] hsh the hash to be converted.
        # --------------------------------------------------------------------

        def hash(hsh)
          hsh.each_with_object({}) do |(key, val), new_hsh|
            new_hsh[key.to_s] = convert(val)
          end
        end

        # --------------------------------------------------------------------
        # Stringify an Array's keys, unless it's an allow value type.
        # @param [Array] ary the array to be converted.
        # --------------------------------------------------------------------

        def array(ary)
          ary.each_with_object([]) do |key, new_ary|
            new_ary << convert(key)
          end
        end

        # --------------------------------------------------------------------

        def set(set)
          return Set.new(array(set))
        end

        # --------------------------------------------------------------------
        # Determines if we should convert a value to a string by checking
        # the class and if the class doesn't match, it stringifies.
        # --------------------------------------------------------------------

        def allowed?(value)
          ALLOWED_CLASSES.any? do |val|
            value.is_a?(val)
          end
        end

        # --------------------------------------------------------------------

        def convert(object)
          return hash(object) if object.is_a?(Hash)
          return array(object) if object.is_a?(Array)
          return set(object) if object.is_a?(Set)
          return object.to_s unless allowed?(object)
          object
        end
      end
    end
  end
end
