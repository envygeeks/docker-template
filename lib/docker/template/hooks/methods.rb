# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Hooks
      module Methods
        def self.included(klass)
          klass.send :extend, Forwardable
          klass.def_delegator :"self.class", :hook_base
          klass.def_delegator :"self.class", :hooks

          klass.send :extend, Klass
          const = klass.const_set(:HookMethods, Module.new)
          klass.send(:include, const)
        end

        #

        def any_hooks?(point)
          Hooks.get_point(self, point).fetch(:hooks).any?
        end

        #

        def run_hooks(point, *args)
          Hooks.run(self, point, *args)
        end

        #

        module Klass
          def register_hook_point(*points)
            points.each do |point|
              Hooks.register_point point, self
            end
          end
        end
      end
    end
  end
end
