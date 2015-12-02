# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

class Pathname
  def in_path?(path)
    path_str = path.is_a?(self.class) ? path.expanded_realpath.to_s : path.to_s
    expanded_realpath.to_s.start_with?(path_str)
  end

  #

  def write(data)
    File.write(self.to_s, data)
  end

  #

  def expanded_path
    @expanded_path ||= begin
      expand_path Dir.pwd
    end
  end

  #

  def expanded_realpath
    return @expanded_real_path ||= begin
      expanded_path.realpath
    end
  end

  #

  def all_children
    glob "**/*"
  end

  #

  def glob(*args)
    Dir.glob(self.join(*args)).map do |path|
      self.class.new(path)
    end
  end
end
