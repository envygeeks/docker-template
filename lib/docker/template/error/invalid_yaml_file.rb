# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Error
      class InvalidYAMLFile < StandardError
        def initialize(file)
          super "The yaml data provided by #{file} is invalid and not a hash."
        end
      end
    end
  end
end
