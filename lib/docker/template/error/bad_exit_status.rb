# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Error
      class BadExitStatus < StandardError
        attr_reader :status

        def initialize(status)
          super "Got bad exit status #{
            @status = status
          }"
        end
      end
    end
  end
end
