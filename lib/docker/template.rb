# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8


require "docker"
require "forwardable"
require "simple/ansi"
require "pathname"
require "json"
require "erb"
require "set"

# Set some defaults, as well as increase the timeout since sometimes Alpine dl is slow.
Excon.defaults[:headers]["User-Agent"] = "docker-template/#{Docker::Template::VERSION}"
Excon.defaults[:read_timeout] = 480

module Docker
  module Template
    module_function
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
      data = Util::Data.new(data)
      template = template_root.join("#{name}.erb").read
      ERB.new(template).result(data._binding)
    end
  end
end

require "docker/template/error"
require "docker/template/version"
require "docker/template/patches"
require "docker/template/routable"
require "docker/template/hooks"
require "docker/template/util"
require "docker/template/config"
require "docker/template/stream"
require "docker/template/repo"
require "docker/template/rootfs"
require "docker/template/scratch"
require "docker/template/normal"
