# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

class Array
  def stringify
    map do |val|
      val.is_a?(Hash) || val.is_a?(Array) ? val.stringify : val.to_s
    end
  end
end
