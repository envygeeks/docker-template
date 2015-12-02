# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Error
      class NoRootfsCopyDir < StandardError
        def initialize
          super "Unable to find your rootfs copy folder."
        end
      end
    end
  end
end
