# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Routable
      def route_to_hash(methods, hash, alt_key = nil)
        methods = [methods] unless methods.is_a?(Array)
        methods.each do |method|
          class_eval <<-STR, __FILE__, __LINE__
            def #{method}
              #{alt_key ? "#{hash}['#{alt_key}']" : "#{hash}['#{method}']"}
            end
          STR
        end
      end

      def route_to_ivar(method, var, bool: false, revbool: false)
        class_eval <<-STR, __FILE__, __LINE__
          def #{method}#{"?" if bool || revbool}
            #{revbool ? "!!!" : "!!" if bool || revbool}#{var}
          end
        STR
      end
    end
  end
end
