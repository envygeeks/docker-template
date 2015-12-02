# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

class Hash
  def to_env
    inject({}) do |hsh, (key, val)|
      val = val.is_a?(Array) ? val.join(" ") : val.to_s
      key = key.to_s.upcase
      hsh[key] = val
    hsh
    end
  end

  #

  def any_keys?(*keys)
    keys.map(&method(:has_key?)).any? do |val|
      val == true
    end
  end

  #

  def leftover_keys?(*keys)
    return (self.keys - keys).any?
  end

  #

  def has_keys?(*keys)
    return false unless rtn = true && any?
    while rtn && key = keys.shift
      rtn = has_key?(key) || false
    end

  rtn
  end

  #

  def to_env_ary
    inject([]) do |array, (key, val)|
      array.push("#{key}=#{val}")
    end
  end

  #

  def deep_merge(newh)
    merge(newh) do |key, oval, nval|
      if oval.is_a?(self.class) && nval.is_a?(self.class)
        then oval.deep_merge(nval) else nval
      end
    end
  end

  #

  def stringify
    inject({}) do |hsh, (key, val)|
      hsh[key.to_s] = val.is_a?(Array) || val.is_a?(Hash) ? val.stringify : val.to_s
    hsh
    end
  end

  #

  def stringify_keys
    inject({}) do |hsh, (key, val)|
      hsh[key.to_s] = val

    hsh
    end
  end
end
