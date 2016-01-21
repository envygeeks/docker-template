# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template

    # * A repo is not an image but a parent name w/ a tag.
    # * An image is the final result of a build on a repo, and is associated.
    # * Think of an image as the binary of the source in the repo.

    class Repo
      extend Forwardable::Extended

      #

      rb_delegate :build, :to => :builder
      rb_delegate :complex_alias?, :to => :metadata
      rb_delegate :type, :to => :metadata, :type => :hash
      rb_delegate :user, :to => :metadata, :type => :hash
      rb_delegate :name, :to => :metadata, :type => :hash
      rb_delegate :tag,  :to => :metadata, :type => :hash
      rb_delegate :pushable?, :to => :metadata, :key => :push, :type => :hash, :bool => true
      rb_delegate :syncable?, :to => :metadata, :key => :sync, :type => :hash, :bool => true
      rb_delegate :to_h, :to => :@base_metadata
      rb_delegate :alias?, :to => :metadata
      rb_delegate :tags,   :to => :metadata

      def initialize(base_metadata = {}, cli_opts = {})
        raise ArgumentError, "Metadata not a hash" unless base_metadata.is_a?(Hash)
        raise ArgumentError, "CLI Opts not a hash" unless cli_opts.is_a?(Hash)

        @cli_opts = cli_opts.freeze
        @base_metadata = base_metadata.freeze
        raise Error::InvalidRepoType, type unless Template.config.build_types.include?(type)
        raise Error::RepoNotFound unless root.exist?
      end

      #

      def builder
        const = Template.const_get(type.capitalize)
        const.new(self)
      end

      #

      def to_s(rootfs: false)
        prefix = metadata["local_prefix"]
        return "#{user}/#{name}:#{tag}" unless rootfs
        "#{prefix}/rootfs:#{name}"
      end

      #

      def cache_dir
        dir = metadata["cache_dir"]
        return root.join(dir, tag) unless tags.one?
        return root.join(dir) if tags.one?
      end

      #

      def copy_dir(*path)
        dir = metadata["copy_dir"]
        root.join(dir, *path)
      end

      #

      def root
        @root ||= begin
          Template.repo_root_for(name)
        end
      end

      #

      def to_tag_h
        {
          "tag"   => tag,
          "repo"  => "#{user}/#{name}",
          "force" => true
        }
      end

      #

      def to_rootfs_h
        {
          "tag"   => name,
          "repo"  => "#{metadata["local_prefix"]}/rootfs",
          "force" => true
        }
      end

      #

      def tmpdir(*prefixes, root: nil)
        prefixes = [user, name, tag] + prefixes
        args = ["#{prefixes.join("-")}-", root].delete_if(&:nil?)
        Pathname.new(Dir.mktmpdir(*args))
      end

      #

      def tmpfile(*prefixes, root: nil)
        prefixes = [user, name, tag] + prefixes
        ext = prefixes.pop if prefixes.last.start_with?(".")
        prefixes = ["#{prefixes.join("-")}-"]
        prefixes = ext ? prefixes.push(ext) : prefixes.first
        args = [prefixes, root].delete_if(&:nil?)
        Pathname.new(Tempfile.new(*args))
      end

      # If a tag was given then it returns [self] and if a tag was not
      # sent it then goes on to detect the type and split itself accordingly
      # returning multiple AKA all repos to be built.

      def to_repos
        set = Set.new
        if @base_metadata.key?("tag")
          set << self
        else
          tags.each do |tag|
            hash = to_h.merge("tag" => tag)
            set << self.class.new(hash, @cli_opts)
          end
        end
        set
      end

      #

      def metadata
        @metadata ||= begin
          root = Template.repo_root_for(@base_metadata["name"])

          metadata = Template.config.read_config_from(root)
          metadata = Metadata.new(metadata, root: true).merge(@base_metadata)
          metadata = metadata.merge(@cli_opts)
          Config.excon_timeouts(metadata)
          metadata
        end
      end

      # rubocop:disable Metrics/AbcSize
      def to_env(tar_gz: nil, copy_dir: nil)
        metadata["env"].as_hash.merge({
          "REPO" => name,
          "NAME" => name,
          "TAR_GZ" => tar_gz,
          "TYPE" => metadata["tags"][tag],
          "VERSION" => metadata["version"].fallback,
          "PKGS" => metadata["pkgs"].as_string_set,
          "RELEASE" => metadata["release"].fallback,
          "BUILD_TYPE" => type,
          "COPY" => copy_dir,
          "TAR" => tar_gz,
          "TAG" => tag
        }).to_env
      end
    end
  end
end
