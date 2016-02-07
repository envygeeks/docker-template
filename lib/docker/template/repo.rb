# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template

    # ------------------------------------------------------------------------
    # * A repo is not an image but a parent name w/ a tag.
    # * An image is the final result of a build on a repo, and is associated.
    # * Think of an image as the binary of the source in the repo.
    # ------------------------------------------------------------------------

    class Repo
      extend Forwardable::Extended

      # ----------------------------------------------------------------------

      rb_delegate :build, :to => :builder
      rb_delegate :complex_alias?, :to => :metadata
      rb_delegate :type, :to => :metadata, :type => :hash
      rb_delegate :user, :to => :metadata, :type => :hash
      rb_delegate :name, :to => :metadata, :type => :hash
      rb_delegate :tag,  :to => :metadata, :type => :hash
      rb_delegate :pushable?,  :to => :metadata, :key => :push,  :type => :hash, :bool => true
      rb_delegate :buildable?, :to => :metadata, :key => :build, :type => :hash, :bool => true
      rb_delegate :syncable?,  :to => :metadata, :key => :sync,  :type => :hash, :bool => true
      rb_delegate :to_h, :to => :@base_metadata
      rb_delegate :alias?, :to => :metadata
      rb_delegate :tags,   :to => :metadata

      # ----------------------------------------------------------------------
      # @param [Hash] cli_opts pretty much anything you want, it's dynamic.
      # @param [Hash] base_metadata { "name" => name, "tag" => tag }
      # ----------------------------------------------------------------------

      def initialize(base_metadata = {}, cli_opts = {})
        raise ArgumentError, "Metadata not a hash" unless base_metadata.is_a?(Hash)
        raise ArgumentError, "CLI Opts not a hash" unless cli_opts.is_a?(Hash)

        @cli_opts = cli_opts.freeze
        @base_metadata = base_metadata.freeze
        raise Error::InvalidRepoType, type unless Template.config.build_types.include?(type)
        raise Error::RepoNotFound unless root.exist?
      end

      # ----------------------------------------------------------------------

      def aliased
        if alias?
          self.class.new(to_h.merge({
            "tag" => metadata.aliased
          }))
        end
      end

      # ----------------------------------------------------------------------

      def builder
        return @builder ||= begin
          Template.const_get(type.capitalize).new(
            self
          )
        end
      end

      # ----------------------------------------------------------------------
      # There is a difference between how we name normal images and how we
      # name rootfs images, this way you can easily point them out when doing
      # something like `docker images` that is... if you save the image.
      # ----------------------------------------------------------------------

      def to_s(rootfs: false)
        prefix = metadata["local_prefix"]
        return "#{user}/#{name}:#{tag}" unless rootfs
        "#{prefix}/rootfs:#{name}"
      end

      # ----------------------------------------------------------------------
      # The directory you wish to cache to (like `cache`, `sync`) or other.
      # ----------------------------------------------------------------------

      def cache_dir
        dir = metadata["cache_dir"]
        return root.join(dir, tag) unless tags.one?
        return root.join(dir) if tags.one?
      end

      # ----------------------------------------------------------------------
      # The directory you store your image data in (by default `copy/`)
      # ----------------------------------------------------------------------

      def copy_dir(*path)
        dir = metadata["copy_dir"]
        root.join(dir, *path)
      end

      # ----------------------------------------------------------------------

      def root
        @root ||= begin
          Template.repo_root_for(name)
        end
      end

      # ----------------------------------------------------------------------
      # This hash is mostly used for upstream work, not locally.
      # ----------------------------------------------------------------------

      def to_tag_h
        {
          "tag"   => tag,
          "repo"  => "#{user}/#{name}",
          "force" => true
        }
      end

      # ----------------------------------------------------------------------
      # This hash is mostly used for upstream work, not locally.
      # ----------------------------------------------------------------------

      def to_rootfs_h
        {
          "tag"   => name,
          "repo"  => "#{metadata["local_prefix"]}/rootfs",
          "force" => true
        }
      end

      # ----------------------------------------------------------------------
      # Allows you to create a tempoary directory with a prefix if you wish.
      # ----------------------------------------------------------------------

      def tmpdir(*args, root: nil)
        args.unshift(user, name, tag)
        Pathutil.tmpdir(args,
          "docker-template", root
        )
      end

      # ----------------------------------------------------------------------
      # Allows you to create a temporary file with a prefix if you wish.
      # ----------------------------------------------------------------------

      def tmpfile(*args, root: nil)
        args.unshift(user, name, tag)
        Pathutil.tmpfile(args,
          "docker-template", root
        )
      end

      # ----------------------------------------------------------------------
      # If a tag was given then it returns [self] and if a tag was not
      # sent it then goes on to detect the type and split itself accordingly
      # returning multiple AKA all repos to be built.
      # ----------------------------------------------------------------------

      def to_repos
        set = Set.new
        if @base_metadata.key?("tag")
          set << self
        else
          tags.each do |tag|
            hash = to_h.merge("tag" => tag)
            set << self.class.new(
              hash, @cli_opts
            )
          end
        end
        set
      end

      # ----------------------------------------------------------------------

      def metadata
        return @metadata ||= begin
          root = Template.repo_root_for(@base_metadata["name"])

          metadata = Template.config.read_config_from(root)
          metadata = Metadata.new(metadata, root: true).merge(@base_metadata)
          metadata = metadata.merge(@cli_opts)
          Config.excon_timeouts(metadata)
          metadata
        end
      end

      # ----------------------------------------------------------------------

      def to_env(tar_gz: nil, copy_dir: nil)
        metadata["env"].to_h.merge({
          "REPO" => name,
          "NAME" => name,
          "TAR_GZ" => tar_gz,
          "PKGS" => metadata.pkgs,
          "VERSION" => metadata.version,
          "RELEASE" => metadata.release,
          "TYPE" => metadata.tag,
          "BUILD_TYPE" => type,
          "COPY" => copy_dir,
          "TAR" => tar_gz,
          "TAG" => tag
        })
      end
    end
  end
end
