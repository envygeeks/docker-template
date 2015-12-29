# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "docker/template/version"
require "docker/template/patches"

require "docker"
require "forwardable"
require "json"
require "erb"
require "set"

# Set some defaults, as well as increase the timeout since sometimes Alpine dl is slow.
Excon.defaults[:headers]["User-Agent"] = "docker-template/#{Docker::Template::VERSION}"
Excon.defaults[:read_timeout] = 480

module Docker
  module Template
    module_function

    autoload :Hooks, "docker/template/hooks"
    autoload :Util, "docker/template/util"
    autoload :Config, "docker/template/config"
    autoload :Ansi, "docker/template/ansi"
    autoload :Parser, "docker/template/parser"
    autoload :Routable, "docker/template/routable"
    autoload :Interface, "docker/template/interface"
    autoload :Metadata, "docker/template/metadata"
    autoload :Stream, "docker/template/stream"
    autoload :Safe, "docker/template/safe"
    autoload :Repo, "docker/template/repo"
    autoload :Error, "docker/template/error"
    autoload :Common, "docker/template/common"
    autoload :Rootfs, "docker/template/rootfs"
    autoload :Scratch, "docker/template/scratch"
    autoload :Normal, "docker/template/normal"
    autoload :Alias, "docker/template/alias"
    autoload :Auth, "docker/template/auth"

    def repo_is_root?
      root.join("copy").exist? && !root.join(config["repos_dir"]).exist?
    end

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

    # The location of the standard repos/ dir, you can change this by adding
    # `repos_dir` into your configuration file. I'm not saying it has to be but
    # it should probably be relative rather than absolute, ther are no
    # guarantees that an absolute path will work.

    def repos_root
      @repos_root ||= begin
        root.join(config["repos_dir"])
      end
    end

    #

    def repo_root_for(name)
      repo_is_root?? root : repos_root.join(name)
    end

    # Provides the root to Docker template, wherever it is installed so that
    # we can do things, mostly ignore files for the profiler. Otherwise it's
    # not really used, it's just an encapsulator.

    def gem_root
      @gem_root ||= begin
        path = File.expand_path("../../", __dir__)
        Pathname.new(path)
      end
    end

    # Provides the templates directory so you can quickly pull a template
    # from our templates and use it if you wish to.

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
