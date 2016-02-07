# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Utils
      autoload :Notify, "docker/template/utils/notify"
      autoload :Stringify, "docker/template/utils/stringify"
      autoload :Context, "docker/template/utils/context"
      autoload :Data, "docker/template/utils/data"
    end
  end
end
