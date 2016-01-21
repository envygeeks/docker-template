# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class Metadata
      attr_reader :metadata, :root_metadata
      extend Forwardable::Extended

      # Provides aliases for the root element so you can do something like:
      #   * data["release"].fallback

      ALIASES = {
        "entry" => "entries",
        "release" => "releases",
        "version" => "versions",
        "script" => "scripts",
        "image" => "images"
      }.freeze

      rb_delegate :root,     :to => :@root, :type => :ivar, :bool => true
      rb_delegate :for_all,  :to => :self,  :type => :hash, :key  => :all
      rb_delegate :keys,     :to => :@metadata
      rb_delegate :to_enum,  :to => :@metadata
      rb_delegate :size,     :to => :@metadata
      rb_delegate :key?,     :to => :@metadata
      rb_delegate :to_h,     :to => :@metadata
      rb_delegate :each,     :to => :@metadata

      def initialize(metadata, root: false, root_metadata: nil)
        @base = Template.config if root
        @root_metadata = root_metadata.freeze unless root
        @root_metadata = metadata.freeze if root
        @metadata = metadata.freeze
        @root = root

        if !root? && !root_metadata
          raise Docker::Template::Error::NoRootMetadata
        end
      end

      #

      def complex_alias?
        return false unless alias?
        @root_metadata.select { |_, val| val.is_a?(Hash) && val.key?("tag") }.any? do |_, val|
          val["tag"].key?(from_root("tag"))
        end
      end

      #

      def alias?
        return @alias ||= begin
          aliased != from_root("tag")
        end
      end

      #

      def as_gem_version
        "#{from_root("name")}@#{self["version"].fallback}"
      end

      #

      def aliased
        tag = from_root("tag")
        aliases = from_root("aliases")
        return aliases[tag] if aliases.key?(tag)
        tag
      end

      # Queries providing a default value if on the root repo hash otherwise
      # returning the returned value, as a `self.class` if it's a Hash.

      def [](key)
        key = determine_key(key.to_s)
        val = @metadata[key]

        return try_default(key) if !val && root?
        return self.class.new(val, root_metadata: @root_metadata) if val.is_a?(Hash)
        val
      end

      #

      def tags
        from_root("tags").keys | from_root("aliases").keys
      end

      #

      def merge(new_)
        @metadata = @metadata.merge(Utils::Stringify.hash(new_))
        @root_metadata = @metadata if root?
        self
      end

      #

      def as_string_set
        as_set.to_a.join(" ")
      end

      #

      def as_hash
        {} \
          .merge(for_all.to_h) \
          .merge(by_type.to_h) \
          .merge(by_tag. to_h)
      end

      #

      def as_set
        Set.new \
          .merge(for_all.to_a) \
          .merge(by_type.to_a) \
          .merge(by_tag .to_a)
      end

      #

      def from_root(key)
        return self[key] if root?
        root = self.class.new(@root_metadata, root: true)
        root[key]
      end

      #

      def fallback
        by_tag || by_type || for_all
      end

      # Pulls data based on the given tag through anything that provides a
      # "tag" key with the given tags. ("tags" is a `Hash`)

      def by_tag
        alias_ = aliased
        tag = from_root("tag")
        return unless key?("tag")
        hash = self["tag"]

        return hash[tag] if alias_ == tag
        merge_or_override(hash[tag], hash[alias_])
      end

      # Pull data based on the type given in { "tags" => { tag => type }}
      # through anything that provides a "type" key with the type as a
      # sub-key and the values.

      def by_type
        tag = aliased
        type = from_root("tags")[tag]
        return unless key?("type")
        return unless type
        self["type"][type]
      end

      #

      private
      def determine_key(key)
        if root? && !key?(key) && ALIASES.key?(key)
          key = ALIASES[key]
        end
        key
      end

      #

      private
      def try_default(key)
        val = @base[key]
        return self.class.new(val, root_metadata: @root_metadata) if val.is_a?(Hash)
        val
      end

      #

      private
      def merge_or_override(val, new_val)
        return new_val unless val
        return val if val.is_a?(String) && !new_val || !new_val.is_a?(val.class)
        return new_val.merge(val) if val.respond_to?(:merge)
        return new_val | val if val.respond_to?(:|)
      end
    end
  end
end
