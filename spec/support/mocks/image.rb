# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Mocks
  class Image
    def tag(*args, &block); end
    def delete(*args, &block); end
    def push(*args, &block); end
    def id(*args, &block); end
  end
end
