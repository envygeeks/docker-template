# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Error
      class InvalidRepoType < StandardError
        def initialize(type)
          build_types = Template.config.build_types.join(", ")
          super "Uknown repo type given '#{type}' not in '#{build_types}'"
        end
      end
    end
  end
end
