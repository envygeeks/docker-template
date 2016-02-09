# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "docker"
require "erb/context"
require "forwardable/extended"
require "docker/template/patches"
require "simple/ansi"
require "pathutil"
require "set"

module Docker
  module Template
    module_function

    # ------------------------------------------------------------------------

    autoload :Repo, "docker/template/repo"
    autoload :Error, "docker/template/error"
    autoload :Logger, "docker/template/logger"
    autoload :Normal, "docker/template/normal"
    autoload :Parser, "docker/template/parser"
    autoload :Builder, "docker/template/builder"
    autoload :Metadata, "docker/template/metadata"
    autoload :Stringify, "docker/template/stringify"
    autoload :Scratch, "docker/template/scratch"
    autoload :Notify, "docker/template/notify"
    autoload :Config, "docker/template/config"
    autoload :Rootfs, "docker/template/rootfs"
    autoload :Cache, "docker/template/cache"
    autoload :CLI, "docker/template/cli"

    # ------------------------------------------------------------------------
    # Checks to see if the repository is the actual root of everything.
    # @note This happens when you do not have a repos folder.
    # ------------------------------------------------------------------------

    def repo_is_root?
      root.join("copy").exist? && !root.join(config["repos_dir"]).exist?
    end

    # ------------------------------------------------------------------------
    # The configuration pulled from `opts.yml`
    # ------------------------------------------------------------------------

    def config
      @config ||= begin
        Config.new
      end
    end

    # ------------------------------------------------------------------------

    def root
      @root ||= begin
        Pathutil.new(Dir.pwd)
      end
    end

    # ------------------------------------------------------------------------

    def repos_root
      root.join(config[
        "repos_dir"
      ])
    end

    # ------------------------------------------------------------------------
    # Pulls the repository root depending on the type of root folder.
    # @param [String,Symbol] the name of the repo.
    # ------------------------------------------------------------------------

    def repo_root_for(name)
      repo_is_root?? root : repos_root.join(name)
    end

    # ------------------------------------------------------------------------

    def gem_root
      @gem_root ||= begin
        Pathutil.new("../../").expand_path(
          __dir__
        )
      end
    end

    # ------------------------------------------------------------------------

    def template_root
      @template_root ||= begin
        gem_root.join("templates")
      end
    end

    # ------------------------------------------------------------------------
    # Pull a `template` from the `template_root` to parse it's data.
    # @param [String,Symbol] name the name of the template from templates/*
    # @param data any data you wish to be encapsulated into it.
    # ------------------------------------------------------------------------

    def get(name, data = {})
      data = ERB::Context.new(data)
      template = template_root.join("#{name}.erb").read
      template = ERB.new(template)

      return template.result(
        data._binding
      )
    end
  end
end
