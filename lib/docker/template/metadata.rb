# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    class Metadata
      attr_reader :root_metadata
      extend Forwardable::Extended
      attr_reader :metadata

      # ----------------------------------------------------------------------
      # Provides aliases for the root element so you can do something like:
      #   * data["release"].fallback
      # ----------------------------------------------------------------------

      ALIASES = {
        "entry" => "entries",
        "release" => "releases",
        "version" => "versions",
        "script" => "scripts",
        "image" => "images"
      }.freeze

      # ----------------------------------------------------------------------

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

      # ----------------------------------------------------------------------
      # A complex alias happens when the user has an alias but also tries to
      # add extra data, this allows them to use data from all parties.
      # ----------------------------------------------------------------------

      def complex_alias?
        return false unless alias?
        @root_metadata.select { |_, val| val.is_a?(Hash) && val.key?("tag") }.any? do |_, val|
          val["tag"].key?(from_root("tag"))
        end
      end

      # ----------------------------------------------------------------------
      # This happens when the user has the tag in aliases.
      # ----------------------------------------------------------------------

      def alias?
        return @alias ||= begin
          aliased != from_root("tag")
        end
      end

      # ----------------------------------------------------------------------
      # @note This is designed to be used with EnvyGeeks helpers.
      # Outputs the version info as "gem@version".
      # ----------------------------------------------------------------------

      def to_gem_version
        "#{from_root("name")}@#{self["version"].fallback}"
      end

      # ----------------------------------------------------------------------
      # Pulls out the tag or the alias name.
      # ----------------------------------------------------------------------

      def aliased
        tag = from_root("tag")
        aliases = from_root("aliases")
        return aliases[tag] if aliases.key?(tag)
        tag
      end

      # ----------------------------------------------------------------------
      # Queries providing a default value if on the root repo hash otherwise
      # returning the returned value, as a `self.class` if it's a Hash.
      # ----------------------------------------------------------------------

      def [](key)
        key = determine_key(key.to_s)
        val = @metadata[key]

        return try_default(key) if !key?(key) && root?
        return self.class.new(val, :root_metadata => @root_metadata) if val.is_a?(Hash)
        val
      end

      # ----------------------------------------------------------------------

      def tags
        from_root("tags").keys | from_root("aliases").keys
      end

      # ----------------------------------------------------------------------

      def merge(new_)
        @metadata = @metadata.merge(Utils::Stringify.hash(new_))
        @root_metadata = @metadata if root?
        self
      end

      # ----------------------------------------------------------------------

      def to_string_set
        return to_set.to_a.join(" ")
      end

      # ----------------------------------------------------------------------
      # rb_delegate :to_h, :to => :@metadata
      # ----------------------------------------------------------------------

      def to_h(raw: !can_fallback?)
        return @metadata.to_h if raw

        {} \
          .merge(for_all.to_h) \
          .merge(by_group.to_h) \
          .merge(by_tag. to_h)
      end

      # ----------------------------------------------------------------------

      def can_fallback?
        (@metadata.keys - %w(group tag all)).empty?
      end

      # ----------------------------------------------------------------------

      def to_set
        Set.new \
          .merge(for_all.to_a) \
          .merge(by_group.to_a) \
          .merge(by_tag .to_a)
      end

      # ----------------------------------------------------------------------
      # Pulls data from the root metadata if this is a sub-metadata instance.
      # ----------------------------------------------------------------------

      def from_root(key)
        return self[key] if root?
        root = self.class.new(@root_metadata, root: true)
        root[key]
      end

      # ----------------------------------------------------------------------

      def fallback
        by_tag || by_group || for_all
      end

      # ----------------------------------------------------------------------
      # Pulls data based on the given tag through anything that provides a
      # "tag" key with the given tags. ("tags" is a `Hash`)
      # ----------------------------------------------------------------------

      def by_tag
        alias_ = aliased
        tag = from_root("tag")
        return unless key?("tag")
        hash = self["tag"]

        return hash[tag] if alias_ == tag
        merge_or_override(hash[tag], hash[alias_])
      end

      # ----------------------------------------------------------------------
      # Pull data based on the group given in { "tags" => { tag => group }}
      # through anything that provides a "group" key with the group as a
      # sub-key and the values.
      # ----------------------------------------------------------------------

      def by_group
        tag = aliased
        group = from_root("tags")[tag]
        return unless key?("group")
        return unless group
        self["group"][
          group
        ]
      end

      # ----------------------------------------------------------------------
      # Checks to see if the key is an alias and returns that master key.
      # ----------------------------------------------------------------------

      private
      def determine_key(key)
        if root? && !key?(key) && ALIASES.key?(key)
          key = ALIASES[
            key
          ]
        end

        key
      end

      # ----------------------------------------------------------------------

      private
      def try_default(key)
        val = @base[
          key
        ]

        if val.is_a?(Hash)
          return self.class.new(val, {
            :root_metadata => @root_metadata
          })
        end

        val
      end

      # ----------------------------------------------------------------------

      private
      def merge_or_override(val, new_val)
        return new_val unless val
        return val if val.is_a?(String) && !new_val || !new_val.is_a?(val.class)
        return new_val.merge(val) if val.respond_to?(:merge)
        return new_val | val if val.respond_to?(:|)
      end

      # ----------------------------------------------------------------------
      # Provides a wrapper for common delegations through `rb_delegate`
      # @note expects that `obj` will have a `fallback` and `can_fallback?`.
      # @return <Object> the resulting value or it's fallback.
      # ----------------------------------------------------------------------

      def fallback_wrapper(obj)
        if obj.respond_to?(:fallback) && obj.can_fallback?
          return obj.fallback
        end

        obj
      end

      # ----------------------------------------------------------------------

      rb_delegate :root,      :to => :@root, :type => :ivar, :bool => true
      rb_delegate :for_all,   :to => :self,  :type => :hash, :key  => :all
      rb_delegate :keys,      :to => :@metadata
      rb_delegate :size,      :to => :@metadata
      rb_delegate :values_at, :to => :@metadata
      rb_delegate :to_enum,   :to => :@metadata
      rb_delegate :key?,      :to => :@metadata
      rb_delegate :each,      :to => :@metadata

      # ----------------------------------------------------------------------
      # Delegate common hash keys as methods so you can easily access them.
      # ----------------------------------------------------------------------

      rb_delegate :tag,          :to => :self, :type => :hash, :wrap => :fallback_wrapper
      rb_delegate :version,      :to => :self, :type => :hash, :wrap => :fallback_wrapper
      rb_delegate :dev_packages, :to => :self, :type => :hash, :wrap => :fallback_wrapper
      rb_delegate :packages,     :to => :self, :type => :hash, :wrap => :fallback_wrapper
      rb_delegate :entry,        :to => :self, :type => :hash, :wrap => :fallback_wrapper
      rb_delegate :env,          :to => :self, :type => :hash, :wrap => :fallback_wrapper

      # ----------------------------------------------------------------------
    end
  end
end
