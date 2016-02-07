# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template

    # ------------------------------------------------------------------------
    # Configuration is a global version of meatadata, where anything
    # that can be set on configuration can be optimized and stored globally
    # in a opts.{json,yml} file in the current working directory.
    # ------------------------------------------------------------------------

    class Config
      extend Forwardable::Extended

      # ----------------------------------------------------------------------

      rb_delegate :has_default?, :to => :@config, :alias_of => :key?
      rb_delegate :merge,        :to => :@config
      rb_delegate :keys,         :to => :@config
      rb_delegate :to_enum,      :to => :@config
      rb_delegate :to_h,         :to => :@config
      rb_delegate :key?,         :to => :@config
      rb_delegate :each,         :to => :@config
      rb_delegate :[],           :to => :@config

      # ----------------------------------------------------------------------

      YAML_OPTS = {
        :whitelist_classes => [Regexp]
      }.freeze

      # ----------------------------------------------------------------------

      DEFAULTS = {
        "build" => true,
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
        "tty" => false,

        "env"      => { "tag" => {}, "group" => {}, "all" => nil },
        "pkgs"     => { "tag" => {}, "group" => {}, "all" => nil },
        "entries"  => { "tag" => {}, "group" => {}, "all" => nil },
        "releases" => { "tag" => {}, "group" => {}, "all" => nil },
        "versions" => { "tag" => {}, "group" => {}, "all" => nil },
        "aliases"  => {},
        "tags"     => {}
      }.freeze

      # ----------------------------------------------------------------------

      EMPTY_DEFAULTS = {
        "tags" => { "latest" => "normal" }.freeze
      }.freeze

      # ----------------------------------------------------------------------

      def initialize
        setup
      end

      # ----------------------------------------------------------------------

      def reload
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

        Utils::Stringify.hash(
          data
        )
      end

      # ----------------------------------------------------------------------
      # Set sane Excon defaults because Docker can sometimes be slow since
      # 1.8 was released.  We don't want it to get in your way.
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
        @config = DEFAULTS.deep_merge(read_config_from)
        @config = @config.merge(EMPTY_DEFAULTS) do |_, oval, nval|
          oval.nil? || oval.empty?? nval : oval
        end.freeze
      end
    end
  end
end
