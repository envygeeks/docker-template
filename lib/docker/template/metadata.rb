# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "active_support/inflector"
require "active_support/core_ext/hash/indifferent_access"
require "yaml"

module Docker
  module Template
    class Metadata
      attr_reader :data
      extend Forwardable::Extended

      # ----------------------------------------------------------------------
      # rubocop:disable Style/MultilineBlockLayout
      # ----------------------------------------------------------------------

      OPTS_FILE = "opts.yml"
      [Pathutil.allowed[:yaml][:classes], Array.allowed[:keys], \
          Hash.allowed[:vals]].each do |v| v.push(
            self, HashWithIndifferentAccess, Regexp
          )
      end

      # ----------------------------------------------------------------------
      # rubocop:enable Style/MultilineBlockLayout
      # ----------------------------------------------------------------------

      DEFAULTS = HashWithIndifferentAccess.new({
        "log_filters" => [],
        "push" => false,
        "sync" => false,
        "type" => "normal",
        "user" => "envygeeks",
        "local_prefix" => "local",
        "rootfs_base_img" => "envygeeks/ubuntu",
        "maintainer" => "Jordon Bedwell <jordon@envygeeks.io>",
        "name" => Template.root.basename.to_s,
        "rootfs_template" => "alpine",
        "cache_dir" => "cache",
        "repos_dir" => "repos",
        "copy_dir" => "copy",
        "tag" => "latest",
        "clean" => true,
        "tty" => false,
        "tags" => {}
      }).freeze

      # ----------------------------------------------------------------------
      # @param data [Hash, self.class] - the main data.
      # @param root [Hash, self.class] - the root data.
      # Create a new instance of `self.class`.
      #
      # @example ```
      #   self.class.new({
      #     :hello => :world
      #   })
      # ```
      # ----------------------------------------------------------------------

      def initialize(overrides, root: nil)
        if root.is_a?(self.class)
          then root = root.to_h({
            :raw => true
          })
        end

        if overrides.is_a?(self.class)
          then overrides = overrides.to_h({
            :raw => true
          })
        end

        if root.nil?
          overrides = overrides.stringify
          gdata = Template.root.join(OPTS_FILE).read_yaml
          @data = DEFAULTS.deep_merge(gdata.stringify).deep_merge(overrides)
          tdata = Template.root.join(@data[:repos_dir], @data[:name], OPTS_FILE).read_yaml
          @data = @data.deep_merge(tdata.stringify).deep_merge(overrides)
          @data = @data.stringify.with_indifferent_access

        else
          @data = overrides.stringify.with_indifferent_access
          @root_data = root.stringify \
            .with_indifferent_access
        end
      end

      # ----------------------------------------------------------------------

      def _shas
        return @_shas ||= begin
          self.class.new(Template.gem_root.join("shas.yml").read_yaml, {
            :root => root_data
          })
        end
      end

      # ----------------------------------------------------------------------

      def root_data
        return @root_data || @data
      end

      # ----------------------------------------------------------------------

      def root
        Template.root.join(
          root_data[:repos_dir], root_data[:name]
        )
      end

      # ----------------------------------------------------------------------
      # Check if a part of the hash or a value is inside.
      # @param val [Anytning(), Hash] - The key or key => val you wish check.
      # @example metadata.include?(:key => :val) => true|false
      # @example metadata.include?(:key) => true|false
      # ----------------------------------------------------------------------

      def include?(val)
        if val.is_a?(Hash)
          then val.stringify.each do |k, v|
            unless @data.key?(k) && @data[k] == v
              return false
            end
          end

          true
        else
          @data.include?(
            val
          )
        end
      end

      # ----------------------------------------------------------------------
      # @param key [Anything()] the key you wish to pull.
      # @note we make the getter slightly more indifferent because of tags.
      # Pull an indifferent key from the hash.
      # ----------------------------------------------------------------------

      def [](key)
        val = begin
          if key =~ /^\d+\.\d+$/
            @data[key] || @data[
              key.to_f
            ]

          elsif key =~ /^\d+$/
            @data[key] || @data[
              key.to_i
            ]

          else
            @data[key]
          end
        end

        if val.is_a?(Hash)
          return self.class.new(val, {
            :root => root_data
          })
        end

        val
      end

      # ----------------------------------------------------------------------

      def []=(key, val)
        hash = { key => val }.stringify
        @data.update(
          hash
        )
      end

      # ----------------------------------------------------------------------

      def update(hash)
        @data.update(
          hash.stringify
        )
      end

      # ----------------------------------------------------------------------

      def to_enum
        @data.each_with_object({}) do |(k, v), h|
          if v.is_a?(Hash)
            then v = self.class.new(v, {
              :root => root_data
            })
          end

          h[k] = v
        end.to_enum
      end

      # ----------------------------------------------------------------------
      # Merge a hash into the metadata.  If you merge non-queryable data
      # it will then get merged into the queryable data.
      # ----------------------------------------------------------------------

      def merge(new_)
        if !queryable?(:query_data => new_) && queryable?
          new_ = {
            :all => new_
          }
        end

        new_ = new_.stringify
        self.class.new(@data.deep_merge(new_), {
          :root => root_data
        })
      end

      # ----------------------------------------------------------------------
      # Destructive merging (@see self#merge)
      # ----------------------------------------------------------------------

      def merge!(new_)
        if !queryable?(:query_data => new_) && queryable?
          new_ = {
            :all => new_
          }
        end

        @data = @data.deep_merge(
          new_.stringify
        )

        self
      end

      # --------------------------------------------------------------------
      # Check if a hash is queryable. AKA has "all", "group", "tag".
      # --------------------------------------------------------------------

      def queryable?(query_data: @data)
        if query_data.is_a?(self.class)
          then query_data \
            .queryable?

        elsif !query_data || !query_data.is_a?(Hash) || query_data.empty?
          return false

        else
          (query_data.keys - %w(
            group tag all
          )).empty?
        end
      end

      # --------------------------------------------------------------------
      # Fallback, determining which route is the best.  Tag > Group > All.
      # --------------------------------------------------------------------

      def fallback(group: current_group, tag: current_tag, query_data: @data)
        if query_data.is_a?(self.class)
          then query_data.fallback({
            :group => group, :tag => tag
          })

        elsif !query_data || !query_data.is_a?(Hash) || query_data.empty?
          return nil

        else
          by_tag(:tag => tag, :query_data => query_data) || \
            by_parent_tag(:tag => tag, :query_data => query_data) || \
            by_group(:group => group, :query_data => query_data) || \
            by_parent_group(:tag => tag, :query_data => query_data) || \
            for_all(:query_data => query_data)
        end
      end

      # --------------------------------------------------------------------

      def for_all(query_data: @data)
        if query_data.is_a?(self.class)
          then query_data \
            .for_all

        elsif !query_data || !query_data.is_a?(Hash)
          return nil

        else
          query_data.fetch(
            "all", nil
          )
        end
      end

      # --------------------------------------------------------------------

      def by_tag(tag: current_tag, query_data: @data)
        if query_data.is_a?(self.class)
          then query_data.by_tag({
            :tag => tag
          })

        elsif !query_data || !query_data.is_a?(Hash)
          return nil

        else
          query_data.fetch("tag", {}).fetch(
            tag, nil
          )
        end
      end

      # ----------------------------------------------------------------------

      def by_parent_tag(tag: current_tag, query_data: @data)
        if aliased_tag == current_tag || !complex_alias?
          return nil

        else
          by_tag({
            :query_data => query_data,
            :tag => aliased_tag({
              :tag => tag
            })
          })
        end
      end

      # --------------------------------------------------------------------

      def by_group(group: current_group, query_data: @data)
        if query_data.is_a?(self.class)
          then query_data.by_group({
            :group => group
          })

        elsif !query_data || !query_data.is_a?(Hash)
          return nil

        else
          query_data.fetch("group", {}).fetch(
            group, nil
          )
        end
      end

      # ----------------------------------------------------------------------

      def by_parent_group(tag: current_tag, query_data: @data)
        if aliased_tag == current_tag || !complex_alias?
          return nil

        else
          by_group({
            :query_data => query_data,
            :group => aliased_group({
              :tag => tag
            })
          })
        end
      end

      # ----------------------------------------------------------------------
      # Checks to see if the current metadata is an alias of another. This
      # happens when the user has the tag in aliases but it's not complex.
      # ----------------------------------------------------------------------

      def alias?
        !!(aliased_tag && aliased_tag != tag)
      end

      # ----------------------------------------------------------------------
      # A complex alias happens when the user has an alias but also tries to
      # add extra data, this allows them to use data from all parties. This
      # allows them to reap the benefits of having shared data but sometimes
      # independent data that diverges into it's own.
      # ----------------------------------------------------------------------

      def complex_alias?
        if !alias?
          return false

        else
          !!root_data.find do |_, v|
            (v.is_a?(self.class) || v.is_a?(Hash)) && queryable?(:query_data => v) \
              && by_tag(:query_data => v)
          end
        end
      end

      # ----------------------------------------------------------------------

      def aliased_tag(tag: current_tag)
        aliases = root_data[:aliases]
        if aliases.nil? || !aliases.key?(tag)
          tag

        else
          aliases[
            tag
          ]
        end
      end

      # ----------------------------------------------------------------------

      def aliased_group(tag: current_tag)
        root_data[:tags][aliased_tag({
          :tag => tag
        })]
      end

      # ----------------------------------------------------------------------
      # Converts the current meta into a string.
      # ----------------------------------------------------------------------

      def to_s(raw: false, shell: false)
        if !raw && (mergeable_hash? || mergeable_array?)
          to_a(:shell => shell).join(" #{
            "\n" if shell
          }")

        elsif !raw && queryable?
          then fallback \
            .to_s

        else
          @data.to_s
        end
      end

      # ----------------------------------------------------------------------

      def to_a(raw: false, shell: false)
        if raw
          return to_h({
            :raw => true
          }).to_a

        elsif !mergeable_array?
          to_h.each_with_object([]) do |(k, v), a|
            a << "#{k}=#{
              shell ? v.to_s.shellescape : v
            }"
          end
        else
          (for_all || []) | (by_parent_group || []) | (by_group || []) | \
            (by_parent_tag || []) | (by_tag || [])
        end
      end

      # ----------------------------------------------------------------------
      # Convert a `Metadata' into a normal hash. If `self' is queryable then
      # we go and start merging values smartly.  This means that we will merge
      # all the arrays into one another and we will merge hashes into hashes.
      # ----------------------------------------------------------------------

      def to_h(raw: false)
        return @data.to_h if raw || !queryable? || !mergeable_hash?
        keys = [for_all, by_group, by_parent_group, by_tag, \
          by_parent_tag].compact.map(&:keys)

        keys.reduce(:+).each_with_object({}) do |k, h|
          vals = [for_all, by_group, by_parent_group, by_tag, \
            by_parent_tag].compact

          h[k] = \
            if mergeable_array?(k)
              vals.map { |v| v[k].to_a } \
                .compact.reduce(
                  :+
                )

            elsif mergeable_hash?(k)
              vals.map { |v| v[k].to_h } \
                .compact.reduce(
                  :deep_merge
                )

            else
              vals.find do |v|
                v[k]
              end \
              [k]
            end
        end
      end

      # ----------------------------------------------------------------------

      def mergeable_hash?(key = nil)
        return false unless queryable?
        vals = [by_parent_tag, by_parent_group, \
          by_tag, for_all, by_group].compact

        if key
          vals = vals.map do |val|
            val[key]
          end
        end

        !vals.empty? && !vals.any? do |val|
          !val.is_a?(Hash) && !val.is_a?(
            self.class
          )
        end
      end

      # ----------------------------------------------------------------------

      def mergeable_array?(key = nil)
        return false unless queryable?
        vals = [by_parent_tag, by_parent_group, \
          by_tag, for_all, by_group].compact

        if key
          vals = vals.map do |val|
            val[key]
          end
        end

        !vals.empty? && !vals.any? do |val|
          !val.is_a?(
            Array
          )
        end
      end

      # ----------------------------------------------------------------------

      def current_group
        root_data[:tags][current_tag] ||
          "normal"
      end

      # ----------------------------------------------------------------------
      # HELPER: Get a list of all the tags.
      # ----------------------------------------------------------------------

      def tags
        (root_data[:tags] || {}).keys | (root_data[:aliases] || {}).keys
      end

      # ----------------------------------------------------------------------
      # HELPER: Get a list of all the groups.
      # ----------------------------------------------------------------------

      def groups
        root_data["tags"].values.uniq
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

      private
      def string_wrapper(obj, shell: false)
        return obj if obj == true  ||  obj == false  ||  obj.nil?
        return obj.to_s(:shell => shell) if obj.is_a?(self.class)
        !obj.is_a?(Array) ? obj.to_s : obj.join(
          "\s"
        )
      end

      # ----------------------------------------------------------------------

      private
      def method_missing(method, *args, shell: false, &block)
        key = method.to_s.gsub(/\?$/, "")
        val = self[key] || self[key.singularize] \
           || self[key.pluralize]

        if !args.empty? || block_given?
          super

        elsif method !~ /\?$/
          string_wrapper(
            val, :shell => shell
          )

        else
          val != false && !val.nil? && \
            !val.empty?
        end
      end

      # ----------------------------------------------------------------------

      alias deep_merge merge
      alias group current_group
      rb_delegate :for_all, :to => :self, :type => :hash, :key => :all
      rb_delegate :current_tag, :to => :root_data, :key => :tag, :type => :hash
      rb_delegate :tag, :to => :root_data, :type => :hash, :key => :tag
      rb_delegate :root, :to => :@root, :type => :ivar, :bool => true

      # ----------------------------------------------------------------------

      rb_delegate :fetch,     :to => :@data
      rb_delegate :delete,    :to => :@data
      rb_delegate :empty?,    :to => :@data
      rb_delegate :inspect,   :to => :@data
      rb_delegate :values_at, :to => :@data
      rb_delegate :values,    :to => :@data
      rb_delegate :keys,      :to => :@data
      rb_delegate :key?,      :to => :@data
      rb_delegate :==,        :to => :@data

      # ----------------------------------------------------------------------

      rb_delegate :inject,            :to => :to_enum
      rb_delegate :select,            :to => :to_enum
      rb_delegate :each_with_object,  :to => :to_enum
      rb_delegate :collect,           :to => :to_enum
      rb_delegate :find,              :to => :to_enum
      rb_delegate :each,              :to => :to_enum
    end
  end
end
