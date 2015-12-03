# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

class Hash
  def to_env
    each_with_object({}) do |(key, val), hsh|
      val = val.is_a?(Array) ? val.join(" ") : val.to_s
      key = key.to_s.upcase
      hsh[key] = val
    end
  end

  #

  def any_keys?(*keys)
    keys.map(&method(:key?)).any? do |val|
      val == true
    end
  end

  #

  def leftover_keys?(*keys)
    (self.keys - keys).any?
  end

  #

  def keys?(*keys)
    return false unless rtn = true && any?
    while rtn && key = keys.shift
      rtn = key?(key) || false
    end
    rtn
  end

  #

  def to_env_ary
    each_with_object([]) do |(key, val), ary|
      ary << "#{key}=#{val}"
    end
  end

  #

  def deep_merge(newh)
    merge(newh) do |_, oval, nval|
      if oval.is_a?(self.class) && nval.is_a?(self.class)
        then oval.deep_merge(nval) else nval
      end
    end
  end

  #

  def stringify
    each_with_object({}) do |(key, val), hsh|
      hsh[key.to_s] = val.is_a?(Array) || val.is_a?(Hash) ? val.stringify : val.to_s
    end
  end

  #

  def stringify_keys
    each_with_object({}) do |(key, val), hsh|
      hsh[key.to_s] = val
    end
  end
end
