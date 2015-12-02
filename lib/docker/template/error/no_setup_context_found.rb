# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Error
      class NoSetupContextFound < StandardError
        def initialize
          super "No #setup_context found."
        end
      end
    end
  end
end
