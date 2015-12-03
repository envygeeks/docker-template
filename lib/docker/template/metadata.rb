# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class Metadata
      extend Forwardable, Routable

      # Provides aliases for the root element so you can do something like:
      #   * data["release"].fallback

      Aliases = {
          "entry" =>  "entries",
        "release" => "releases",
        "version" => "versions",
         "script" =>  "scripts",
          "image" =>   "images"
      }

      def_delegator :@metadata, :keys
      def_delegator :@metadata, :size
      def_delegator :@metadata, :to_enum
      def_delegator :@metadata, :has_key?
      def_delegator :@metadata, :inspect
      def_delegator :@metadata, :delete
      def_delegator :@metadata, :each
      def_delegator :@metadata, :to_h
      def_delegator :@metadata, :key?
      route_to_ivar :is_root, :@is_root, bool: true
      route_to_hash :for_all, :self, :all

      def initialize(metadata, root_metadata = metadata)
        @is_root = metadata == root_metadata
        @root_metadata = root_metadata || {}
        @metadata = metadata || {}

        if is_root?
          @base = Template.config
          @root_metadata = @metadata
        end
      end

      #

      def aliased
        aliases = from_root("aliases")
        tag = from_root("tag")

        if aliases.key?(tag)
          return aliases[tag]
        end
      tag
      end

      # Queries providing a default value if on the root repo hash otherwise
      # returning the returned value, as a `self.class` if it's a Hash.

      def [](key)
        key = determine_key(key)
        val = @metadata[key]

        return try_default(key) if !val && is_root?
        return self.class.new(val, @root_metadata) if val.is_a?(Hash)
        val
      end

      #

      def tags
        self["tags"].keys + self["aliases"].keys
      end

      #

      def merge(_new)
        @metadata.merge!(_new)
        self
      end

      #

      def as_string_set
        as_set.to_a.join(" ")
      end

      #

      def as_hash
        {}.merge(for_all.to_h). \
           merge(by_type.to_h). \
           merge(by_tag. to_h)
      end

      #

      def as_set
        Set.new. \
          merge(for_all.to_a). \
          merge(by_type.to_a). \
          merge(by_tag .to_a)
      end

      #

      def from_root(key)
        root = self.class.new(@root_metadata)
        root[key]
      end

      #

      def fallback
        by_tag || by_type || for_all
      end

      # Pulls data based on the given tag through anything that provides a
      # "tag" key with the given tags. ("tags" is a `Hash`)

      def by_tag
        return unless tag = aliased
        return unless key?("tag")
        hash = self["tag"]
        hash[tag]
      end

      # Pull data based on the type given in { "tags" => { tag => type }}
      # through anything that provides a "type" key with the type as a
      # sub-key and the values.

      def by_type
        return unless tag = aliased
        type = @root_metadata["tags"][tag]
        return unless key?("type")
        return unless type

        hash = self["type"]
        hash[type]
      end

      #

      private
      def determine_key(key)
        if is_root? && !key?(key) && Aliases.key?(key)
          key = Aliases[key]
        end
      key
      end

      #

      private
      def try_default(key)
        val = @base[key]
        return self.class.new(val, @root_metadata) if val.is_a?(Hash)
        val
      end
    end
  end
end
