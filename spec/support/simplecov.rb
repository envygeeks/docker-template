# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

if !ENV["DISABLE_COVERAGE"] || ENV["DISABLE_COVERAGE"] == "false"
  require "envygeeks/coveralls"

  SimpleCov.start do
    add_filter "/spec"
    add_filter "/vendor"
  end
end
