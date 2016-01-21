# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "yaml"

module Docker
  module Template

    # Configuration is a global version of meatadata, where anything
    # that can be set on configuration can be optimized and stored globally
    # in a opts.{json,yml} file in the current working directory.

    class Config
      extend Forwardable::Extended

      rb_delegate :has_default?, :to => :@config, :alias_of => :key?
      rb_delegate :merge,        :to => :@config
      rb_delegate :keys,         :to => :@config
      rb_delegate :to_enum,      :to => :@config
      rb_delegate :to_h,         :to => :@config
      rb_delegate :key?,         :to => :@config
      rb_delegate :each,         :to => :@config
      rb_delegate :[],           :to => :@config

      DEFAULTS = {
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

        "env"      => { "tag" => {}, "type" => {}, "all" => nil },
        "pkgs"     => { "tag" => {}, "type" => {}, "all" => nil },
        "entries"  => { "tag" => {}, "type" => {}, "all" => nil },
        "releases" => { "tag" => {}, "type" => {}, "all" => nil },
        "versions" => { "tag" => {}, "type" => {}, "all" => nil },
        "aliases"  => {},
        "tags"     => {}
      }.freeze

      #

      EMPTY_DEFAULTS = {
        "tags" => { "latest" => "normal" }
      }

      #

      def initialize
        setup
      end

      #

      def reload
        setup
      end

      # Allows you to read a configuration file from a root and get back
      # either the parsed data or a blank hash that can be merged the way you
      # wish to merge it (if you even care to merge it.)

      def read_config_from(dir = Docker::Template.root)
        file = Dir[dir.join("opts.{json,yml}")].first
        return {} unless file && (file = Pathname.new(file)).file?
        data = YAML.load_file(file) if file.extname == ".yml"

        return {} if !data || data.empty?
        raise Error::InvalidYAMLFile, file unless data.is_a?(Hash)
        Utils::Stringify.hash(data)
      end

      #

      def self.excon_timeouts(config = {}, default = 1440)
        Excon.defaults.update({
           :read_timeout => config["excon_timeout"] || default,
          :write_timeout => config["excon_timeout"] || default
        })
      end

      #

      def build_types
        @build_types ||= %W(normal scratch).freeze
      end

      #

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
