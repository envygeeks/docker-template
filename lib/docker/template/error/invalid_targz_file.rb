# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Error
      class InvalidTargzFile < StandardError
        def initialize(tar_gz)
          super "No data was given to the tar.gz file '#{
            tar_gz.basename
          }'"
        end
      end
    end
  end
end
