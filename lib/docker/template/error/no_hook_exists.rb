# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Error
      class NoHookExists < StandardError
        def initialize(base, point)
          super "Unknown hook base '#{base}' or hook point '#{point}'"
        end
      end
    end
  end
end
