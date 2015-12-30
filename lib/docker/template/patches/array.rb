# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

class Array
  def stringify_keys
    map do |val|
      val = val.to_s if val.is_a?(Symbol)
      val = val.stringify_keys if val.is_a?(Hash) || val.is_a?(Array)
      val
    end
  end
end
