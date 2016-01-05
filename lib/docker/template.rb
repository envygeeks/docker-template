# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "docker"
require "forwardable"
require "docker/template/patches/pathname"
require "docker/template/patches/object"
require "docker/template/patches/string"
require "docker/template/patches/hash"
require "docker/template/version"
require "simple/ansi"
require "pathname"
require "set"
require "erb"

module Docker
  module Template
    module_function

    #

    autoload :Alias, "docker/template/alias"
    autoload :Builder, "docker/template/builder"
    autoload :Config, "docker/template/config"
    autoload :Error, "docker/template/error"
    autoload :Interface, "docker/template/interface"
    autoload :Loggers, "docker/template/loggers"
    autoload :Metadata, "docker/template/metadata"
    autoload :Normal, "docker/template/normal"
    autoload :Parser, "docker/template/parser"
    autoload :Repo, "docker/template/repo"
    autoload :Rootfs, "docker/template/rootfs"
    autoload :Routable, "docker/template/routable"
    autoload :Scratch, "docker/template/scratch"
    autoload :Utils, "docker/template/utils"

    #

    def repo_is_root?
      root.join("copy").exist? && \
        !root.join(config["repos_dir"]).exist?
    end

    #

    def config
      @config ||= begin
        Config.new
      end
    end

    #

    def root
      @root ||= begin
        Pathname.new(Dir.pwd)
      end
    end

    #

    def repos_root
      @repos_root ||= begin
        root.join(config["repos_dir"])
      end
    end

    #

    def repo_root_for(name)
      repo_is_root?? root : repos_root.join(name)
    end

    #

    def gem_root
      @gem_root ||= begin
        path = File.expand_path("../../", __dir__)
        Pathname.new(path)
      end
    end

    #

    def template_root
      @template_root ||= begin
        gem_root.join("lib/docker/template/templates")
      end
    end

    #

    def get(name, data = {})
      data = Utils::Data.new(data)
      template = template_root.join("#{name}.erb").read
      ERB.new(template).result(data._binding)
    end
  end
end
