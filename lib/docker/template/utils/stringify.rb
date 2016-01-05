module Docker
  module Template
    module Utils
      module Stringify
        extend self

        #

        ALLOWED_CLASSES = [TrueClass, FalseClass,
          String, Hash, Array, Set]

        #

        def hash(hsh)
          hsh.each_with_object({}) do |(key, val), new_hsh|
            new_hsh[key.to_s] = convert(val)
          end
        end

        #

        def array(ary)
          ary.each_with_object([]) do |key, new_ary|
            new_ary << convert(key)
          end
        end

        #

        def set(set)
          return Set.new(array(set))
        end

        #

        def allowed?(value)
          ALLOWED_CLASSES.any? do |val|
            value.is_a?(val)
          end
        end

        #

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
