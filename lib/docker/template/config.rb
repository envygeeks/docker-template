# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    class Config
      extend Forwardable::Extended

      # ----------------------------------------------------------------------

      YAML_OPTS = {
        :whitelist_classes => [Regexp]
      }.freeze

      # ----------------------------------------------------------------------

      DEFAULTS = {
        "log_filters" => [],
        "push" => false,
        "sync" => false,
        "type" => "normal",
        "user" => "envygeeks",
        "local_prefix" => "local",
        "rootfs_base_img" => "envygeeks/ubuntu",
        "maintainer" => "Jordon Bedwell <jordon@envygeeks.io>",
        "name" => Template.root.basename.to_s,
        "cache_dir" => "cache",
        "repos_dir" => "repos",
        "copy_dir" => "copy",
        "tag" => "latest",
        "clean" => true,
        "tty" => false
      }.freeze

      # ----------------------------------------------------------------------

      def initialize
        setup
      end

      # ----------------------------------------------------------------------
      # Allows you to read a configuration file from a root and get back
      # either the parsed data or a blank hash that can be merged the way you
      # wish to merge it (if you even care to merge it.)
      # ----------------------------------------------------------------------

      def read_config_from(dir = Docker::Template.root)
        data = dir.join("opts.yml").read_yaml(YAML_OPTS) || {}
        unless data.is_a?(Hash)
          raise Error::InvalidYAMLFile, dir.join(
            "opts.yml"
          )
        end

        data.stringify
      end

      # ----------------------------------------------------------------------
      # Set sane Excon defaults because Docker can sometimes be slow since
      # 1.8 was released.  We don't want it to get in your way and block.
      # ----------------------------------------------------------------------

      def self.excon_timeouts(config = {}, default = 1440)
        Excon.defaults[ :read_timeout] = config["excon_timeout"] || default
        Excon.defaults[:write_timeout] = config["excon_timeout"] || default
      end

      # ----------------------------------------------------------------------

      def build_types
        @build_types ||= %W(normal scratch).freeze
      end

      # ----------------------------------------------------------------------

      private
      def setup
        self.class.excon_timeouts
        @config = DEFAULTS.deep_merge(
          read_config_from
        )
      end

      # ----------------------------------------------------------------------

      rb_delegate :merge,        :to => :@config
      rb_delegate :keys,         :to => :@config
      rb_delegate :to_enum,      :to => :@config
      rb_delegate :deep_merge,   :to => :@config
      rb_delegate :values,       :to => :@config
      rb_delegate :to_h,         :to => :@config
      rb_delegate :key?,         :to => :@config
      rb_delegate :each,         :to => :@config
      rb_delegate :[],           :to => :@config
      rb_delegate :has_default?, :to => :@config, \
        :alias_of => :key?
    end
  end
end
