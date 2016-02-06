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
      #   * data["release"].fallback or data.release.fallback if available.
      # ----------------------------------------------------------------------

      ALIASES = {
        "entry" => "entries",
        "release" => "releases",
        "version" => "versions",
        "script" => "scripts",
        "image" => "images"
      }.freeze

      # ----------------------------------------------------------------------
      # @example self.class.new({ :hello => :world }, root: true)
      # @param root [true,false] whether or not this is the root metadata.
      # @param root_metadata [Hash] if this is not root, this is the root metadata.
      # @param metadata [Hash] the metadata you are wrapping.
      #
      # Allows you to wrap a Hash with a bunch of helpers so that users can
      # do fancy stuff with the metadata they receive, including falling back
      # to the default configuration, the passed CLI options and so forth.
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

      def is_a?(obj)
        return true if obj == self.class
        @metadata.is_a?(
          obj
        )
      end

      # ----------------------------------------------------------------------
      # A complex alias happens when the user has an alias but also tries
      # to add extra data, this allows them to use data from all parties. This
      # allows them to reap the benefits of having shared data but sometimes
      # independent data that diverges into it's own single template.
      #
      # @example
      #   aliases:
      #     world: hello
      #
      #   pkgs:
      #     tag:
      #       hello:
      #         - my_package1
      #         - my_package2
      #       world:
      #         - my_package3
      #         - my_package4
      #
      #   tags:
      #     hello: normal
      #     you:   normal
      #
      # As you can see from the example above that when we provide the tag
      # `world` as an alias and then have data for "world" we have created an
      # complex alias, this alias will inherit from both `hello` & `world`.
      # @note This only happens when you use by_tag or a method uses it.
      # ----------------------------------------------------------------------

      def complex_alias?
        return false unless alias?
        data = @root_metadata.select do |_, val|
          val.is_a?(Hash) && val.key?(
            "tag"
          )
        end

        data.any? do |_, val|
          val["tag"].key?(from_root(
            "tag"
          ))
        end
      end

      # ----------------------------------------------------------------------
      # Checks to see if the current metadata is an alias of another. This
      # happens when the user has the tag in aliases but it's not complex.
      # ----------------------------------------------------------------------

      def alias?
        return @alias ||= begin
          aliased != from_root(
            "tag"
          )
        end
      end

      # ----------------------------------------------------------------------
      # Outputs the version info as "gem@version".
      # ----------------------------------------------------------------------

      def to_gem_version
        "#{from_root("name")}@#{self["version"].fallback}"
      end

      # ----------------------------------------------------------------------
      # Pulls out the tag or the tag that the current tag is an alias of.
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
        val = @metadata[
          key
        ]

        if !key?(key) && root?
          return try_default(
            key
          )

        elsif val.is_a?(Hash)
          return self.class.new(val, {
            :root_metadata => @root_metadata
          })
        end

        val
      end

      # ----------------------------------------------------------------------
      # Provides a list of tags and aliases, without their respective group.
      # ----------------------------------------------------------------------

      def tags
        from_root("tags").keys | from_root("aliases").keys
      end

      # ----------------------------------------------------------------------
      # Proviedes a list of groups, without their respective tag.
      # ----------------------------------------------------------------------

      def groups
        from_root("tags").values
      end

      # ----------------------------------------------------------------------
      # Merges data into the metadata, and into the root metadata if root.
      # ----------------------------------------------------------------------

      def merge(new_)
        @metadata = @metadata.merge(Utils::Stringify.hash(new_))
        @root_metadata = @metadata if root?
        self
      end

      # ----------------------------------------------------------------------
      # UPCASES the keys of a hash so they can be transformed further later.
      # ----------------------------------------------------------------------

      def to_env(storage: :default, object: self)
        storage_ = storage == :default ? {} : storage
        out = object.each_with_object(storage_) do |(key, val), hsh|
          if val.is_a?(Array)
            hsh.update({
              key.upcase => val.join(
                " "
              )
            })

          elsif val.is_a?(Hash)
            to_env({
              :storage => hsh,
              :object  => val
            })

          else
            hsh.update({
              key.upcase => val.to_s
            })
          end
        end

        if storage == :default
          self.class.new(out, {
            :root_metadata => @root_metadata
          })
        else
          out
        end
      end

      # ----------------------------------------------------------------------
      # Takes a hash (self) and converts it into an array of keys and values.
      # ----------------------------------------------------------------------

      def to_env_ary
        to_env.each_with_object([]) do |(key, val), ary|
          ary << "#{key}=#{val}"
        end
      end

      # ----------------------------------------------------------------------
      # Takes hash (self) and converts it into a list of key=val envvars.
      # ----------------------------------------------------------------------

      def to_env_str(multiline: false)
        if multiline
          env = to_env_ary
          str = ""

          env[1..-1].each_with_index do |val, index|
            if env.size == 2
              str+= " \\"
            end

            str += "\n  #{
              val
            }"

            unless index == env.size - 2
              str += " \\"
            end
          end

          env.first + \
            str
        else
          to_env_ary.join(
            " "
          )
        end
      end

      # ----------------------------------------------------------------------

      def to_s
        return to_env_str if mergeable_hash?
        if mergeable_array?
          return to_a.join(
            " "
          )
        end

        ""
      end

      # ----------------------------------------------------------------------

      def to_a
        for_all.to_a | \
          by_group.to_a | \
          by_tag.to_a
      end

      # ----------------------------------------------------------------------
      # rb_delegate :to_h, :to => :@metadata
      # ----------------------------------------------------------------------

      def to_h(raw: !fallback?)
        return @metadata.to_h if raw

        {} \
          .merge(for_all.to_h) \
          .merge(by_group.to_h) \
          .merge(by_tag. to_h)
      end

      # ----------------------------------------------------------------------
      # Generically detect if there can be a fallback.
      # ----------------------------------------------------------------------

      def fallback?
        return false if @metadata.empty?

        (@metadata.keys - %w(
          group tag all
        )).empty?
      end

      # ----------------------------------------------------------------------

      def mergeable_hash?
        fallback? && (by_tag.is_a?(Hash) || for_all.is_a?(Hash) || \
        by_group.is_a?(
          Hash
        ))
      end

      # ----------------------------------------------------------------------

      def mergeable_array?
        fallback? && (by_tag.is_a?(Array) || for_all.is_a?(Array) || \
        by_group.is_a?(
          Array
        ))
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
        merge_or_override(hash[tag],
          hash[alias_]
        )
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
      # Tries to pull a value from the base configuration.
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
      # @note expects that `obj` will have a `fallback` and `fallback?`.
      # @return [Object] the resulting value or it's fallback.
      # ----------------------------------------------------------------------

      private
      def fallbacks_wrapper(obj)
        if obj.respond_to?(:fallback?) && obj.fallback?
          return obj.fallback
        end

        obj
      end

      # ----------------------------------------------------------------------
      # Provides a wrapper for common delegations through `rb_delegate`
      # @note expects that `obj` will have a `mergeable` and `mergeable_*?`.
      # @return [Object] the resulting value or it's merged `obj`.
      # ----------------------------------------------------------------------

      private
      def mergeable_wrapper(obj)
        if obj.respond_to?(:mergeable?) && obj.mergeable?
          return obj.to_s
        end

        obj
      end

      # ----------------------------------------------------------------------
      # Allows you to check if a value exists and is true, if you wish to.
      # ----------------------------------------------------------------------

      private
      def method_missing(method, *args, &block)
        return super if !args.empty? || block_given? || method !~ /\?$/
        val = self[method.to_s.gsub(/\?$/, "")]
        val != false && !val.nil? && \
          !val.empty?
      end

      # ----------------------------------------------------------------------
      # Alias methods that act like one another, but can have different names.
      # ----------------------------------------------------------------------

      rb_delegate :release,           :to => :self,  :type => :hash, :wrap => :fallbacks_wrapper
      rb_delegate :entry,             :to => :self,  :type => :hash, :wrap => :fallbacks_wrapper
      rb_delegate :version,           :to => :self,  :type => :hash, :wrap => :fallbacks_wrapper
      rb_delegate :dev_pkgs,          :to => :self,  :type => :hash, :wrap => :mergeable_wrapper
      rb_delegate :pkgs,              :to => :self,  :type => :hash, :wrap => :mergeable_wrapper
      rb_delegate :env,               :to => :self,  :type => :hash, :wrap => :mergeable_wrapper
      rb_delegate :tag,               :to => :self,  :type => :hash, :wrap => :fallbacks_wrapper
      rb_delegate :root,              :to => :@root, :type => :ivar, :bool => true
      rb_delegate :for_all,           :to => :self,  :type => :hash, :key  => :all
      rb_delegate :keys,              :to => :@metadata
      rb_delegate :size,              :to => :@metadata
      rb_delegate :values_at,         :to => :@metadata
      rb_delegate :each_with_object,  :to => :@metadata
      rb_delegate :to_enum,           :to => :@metadata
      rb_delegate :key?,              :to => :@metadata
      rb_delegate :each,              :to => :@metadata
      rb_delegate :dig,               :to => :@metadata
      rb_delegate :empty?,            :to => :@metadata

      # ----------------------------------------------------------------------

      alias kind_of? is_a?
      alias mergeable? \
        fallback?
    end
  end
end
