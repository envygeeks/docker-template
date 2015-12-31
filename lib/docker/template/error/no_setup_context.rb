# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Error
      class NoSetupContext < StandardError
        def initialize
          super "No #setup_context method exists."
        end
      end
    end
  end
end
