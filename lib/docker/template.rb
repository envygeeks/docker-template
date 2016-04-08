# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "docker"
require "extras/all"
require "erb/context"
require "forwardable/extended"
require "simple/ansi"
require "pathutil"
require "set"

# ----------------------------------------------------------------------------

Excon.defaults[ :read_timeout] = 1440
Excon.defaults[:write_timeout] = 1440

# ----------------------------------------------------------------------------

module Docker
  module Template
    module_function

    # ------------------------------------------------------------------------

    autoload :Notify, "docker/template/notify"
    autoload :Utils, "docker/template/utils"
    autoload :Repo, "docker/template/repo"
    autoload :Error, "docker/template/error"
    autoload :Logger, "docker/template/logger"
    autoload :Normal, "docker/template/normal"
    autoload :Parser, "docker/template/parser"
    autoload :Builder, "docker/template/builder"
    autoload :Metadata, "docker/template/metadata"
    autoload :Scratch, "docker/template/scratch"
    autoload :Rootfs, "docker/template/rootfs"
    autoload :Cache, "docker/template/cache"
    autoload :Alias, "docker/template/alias"
    autoload :CLI, "docker/template/cli"

    # ------------------------------------------------------------------------

    def root
      @root ||= begin
        Pathutil.new(Dir.pwd)
      end
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
    # TODO: Rename this get template!
    # ------------------------------------------------------------------------

    def get(name, data = {})
      data = ERB::Context.new(data)
      template = template_root.join("#{name}.erb").read unless name.is_a?(Pathutil)
      template = name.read if name.is_a?(Pathutil)
      template = ERB.new(template)

      return template.result(
        data._binding
      )
    end
  end
end
