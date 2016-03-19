# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

RSpec::Matchers.define :have_const do |const|
  match do |owner|
    owner.const_defined?(const)
  end
end
