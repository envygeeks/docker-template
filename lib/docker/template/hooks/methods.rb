# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
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
        end

        #

        def run_hooks(point, *args)
          Hooks.load_internal(hook_base, point).
          run_with_context(hook_base, point, \
            self, *args)
        end

        #

        module Klass
          def register_hook_name(*points)
            points.each do |point|
              Hooks.register_name hook_base, point
            end
          end

          #

          def hook_base
            name.split(/::/).last.downcase.to_sym
          end

          #

          def hooks
            Hooks[
              hook_base.to_s
            ]
          end
        end
      end
    end
  end
end
