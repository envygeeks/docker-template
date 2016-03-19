# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    class Repo
      extend Forwardable::Extended

      # ----------------------------------------------------------------------

      def initialize(base_metadata = {}, cli_opts = {})
        raise ArgumentError, "Metadata not a hash" unless base_metadata.is_a?(Hash)
        raise ArgumentError, "CLI Opts not a hash" unless cli_opts.is_a?(Hash)

        @cli_opts = cli_opts.freeze
        @base_metadata = base_metadata.freeze
        raise Error::InvalidRepoType, type unless Template.config.build_types.include?(type)
        raise Error::RepoNotFound, name unless root.exist?
      end

      # ----------------------------------------------------------------------
      # Determines whether or not we should (or you should) push the repo.
      # ----------------------------------------------------------------------

      def pushable?
        metadata["push"] || metadata[
          "push_only"
        ]
      end

      # ----------------------------------------------------------------------
      # Determines whether or not we should (or you should) sync the repo.
      # ----------------------------------------------------------------------

      def syncable?
        metadata["sync"] || metadata[
          "sync_only"
        ]
      end

      # ----------------------------------------------------------------------
      # Determines whether or not we should (or you should) build the repo.
      # ----------------------------------------------------------------------

      def buildable?
        !metadata["push_only"] && !metadata[
          "sync_only"
        ]
      end

      # ----------------------------------------------------------------------
      # Pulls out the repo this repo is aliasing it, this happens when you
      # when you set the tag in the "alias" section of your `opts.yml`.
      # ----------------------------------------------------------------------

      def aliased
        if alias?
          self.class.new(to_h.merge({
            "tag" => metadata.aliased
          }))
        end
      end

      # ----------------------------------------------------------------------
      # Initializes and returns the builder so that you can build the repo.
      # ----------------------------------------------------------------------

      def builder
        return @builder ||= begin
          Template.const_get(type.capitalize).new(
            self
          )
        end
      end

      # ----------------------------------------------------------------------
      # Convert the repo into it's final image name, however if you tell, us
      # this is a rootfs build we will convert it into the rootfs name.
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
      # The directory you store your image data in (by default `copy/`.)
      # ----------------------------------------------------------------------

      def copy_dir(*path)
        dir = metadata["copy_dir"]
        root.join(dir,
          *path
        )
      end

      # ----------------------------------------------------------------------
      # Give the full path of the root folder to this image in the repo dir.
      # ----------------------------------------------------------------------

      def root
        @root ||= begin
          Template.repo_root_for(name)
        end
      end

      # ----------------------------------------------------------------------

      def to_tag_h
        {
          "tag"   => tag,
          "repo"  => "#{user}/#{name}",
          "force" => true
        }
      end

      # ----------------------------------------------------------------------

      def to_rootfs_h
        {
          "tag"   => name,
          "repo"  => "#{metadata["local_prefix"]}/rootfs",
          "force" => true
        }
      end

      # ----------------------------------------------------------------------

      def tmpdir(*args, root: nil)
        args.unshift(user, name, tag)
        Pathutil.tmpdir(args,
          "docker-template", root
        )
      end

      # ----------------------------------------------------------------------

      def tmpfile(*args, root: nil)
        args.unshift(user, name, tag)
        Pathutil.tmpfile(args,
          "docker-template", root
        )
      end

      # ----------------------------------------------------------------------
      # If a tag was given then it returns [self] and if a tag was not sent
      # it then goes on to detect the type and split itself accordingly
      # returning multiple, AKA all repos that should be built.
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

      # ----------------------------------------------------------------------

      rb_delegate :build, :to => :builder
      rb_delegate :complex_alias?, :to => :metadata
      rb_delegate :type, :to => :metadata, :type => :hash
      rb_delegate :user, :to => :metadata, :type => :hash
      rb_delegate :name, :to => :metadata, :type => :hash
      rb_delegate :tag,  :to => :metadata, :type => :hash
      rb_delegate :to_h, :to => :@base_metadata
      rb_delegate :alias?, :to => :metadata
      rb_delegate :tags,   :to => :metadata
    end
  end
end
