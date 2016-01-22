# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Error
      class NoRootMetadata < StandardError
        def initialize
          super "Metadata without the root flag must provide the root_metadata."
        end
      end
    end
  end
end
