# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

class Pathname
  module Patches
    def in_path?(path)
      path_str = path.is_a?(self.class) ? path.expanded_realpath.to_s : path.to_s
      expanded_realpath.to_s.start_with?(path_str)
    end

    #

    def join(*args)
      super(*args.map do |val|
        val.to_s.gsub(/\A\//, "")
      end)
    end

    #

    def write(data)
      File.write(to_s, data)
    end

    #

    def expanded_path
      @expanded_path ||= begin
        expand_path Dir.pwd
      end
    end

    #

    def expanded_realpath
      @expanded_real_path ||= begin
        expanded_path.realpath
      end
    end

    #

    def all_children
      glob "**/*"
    end

    #

    def glob(*args)
      Dir.glob(join(*args)).map do |path|
        self.class.new(path)
      end
    end
  end

  prepend Patches
end
