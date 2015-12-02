# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Error
      class NotImplemented < StandardError
        def initialize
          super "The feature is not implemented yet, sorry about that."
        end
      end
    end
  end
end
