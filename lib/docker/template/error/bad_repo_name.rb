# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Error
      class BadRepoName < StandardError
        def initialize(name)
          super "Only a-z0-9_- are allowed. Invalid repo name: #{name}"
        end
      end
    end
  end
end
