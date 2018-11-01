# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class Repo
      extend Forwardable::Extended

      # --

      def initialize(*hashes)
        @base_meta = hashes.compact
        @base_meta = @base_meta.reduce(:deep_merge)
        @base_meta.freeze

        unless root.exist?
          raise(
            Error::RepoNotFound, name
          )
        end
      end

      # --

      def pushable?
        (meta["push"] || meta["push_only"]) &&
          !meta["cache_only"] && !meta[
            "clean_only"
          ]
      end

      # --

      def cacheable?
        (meta["cache"] || meta["cache_only"]) &&
          !meta[
            "push_only"
          ]
      end

      # --

      def clean_cache?
        (meta["clean"] || meta["clean_only"])
      end

      # --

      def buildable?
        meta.build? && !meta["push_only"] && !meta["cache_only"] &&
          !meta[
            "clean_only"
          ]
      end

      # --
      # Pulls out the repo this repo is aliasing it, this happens when you
      # when you set the tag in the "alias" section of your `opts.yml`.
      # --
      def aliased
        full = Parser.full_name?(
          meta.aliased_tag
        )

        if alias? && full
          self.class.new(to_h.merge(Parser.to_repo_hash(
            meta.aliased_tag
          )))

        elsif alias?
          self.class.new(to_h.merge({
            "tag" => meta.aliased_tag
          }))
        end

      rescue Error::RepoNotFound => e
        unless full
          raise e
        end
      end

      # --
      # Initializes and returns the builder so that you can build the repo.
      # --
      def builder
        return @builder ||= begin
          Template::Builder.const_get(type.capitalize).new(
            self
          )
        end
      end

      # --
      # Convert the repo into it's final image name, however if you tell, us
      # this is a rootfs build we will convert it into the rootfs name.
      # --
      def to_s(rootfs: false)
        prefix = meta["local_prefix"]
        return "#{user}/#{name}:#{tag}" unless rootfs
        "#{prefix}/rootfs:#{name}"
      end

      # --
      # The directory you wish to cache to (like `cache/`) or other.
      # --
      def cache_dir
        return root.join(
          meta["cache_dir"], tag
        )
      end

      # --
      # The directory you store your image data in (by default `copy/`.)
      # --
      def copy_dir(*path)
        dir = meta["copy_dir"]
        root.join(
          dir, *path
        )
      end

      # --

      def to_tag_h
        {
          "tag"   => tag,
          "repo"  => "#{user}/#{name}",
          "force" => true
        }
      end

      # --

      def to_rootfs_h
        {
          "tag"   => name,
          "repo"  => "#{meta["local_prefix"]}/rootfs",
          "force" => true
        }
      end

      # --

      def tmpdir(*args, root: Template.tmpdir)
        args.unshift(user.gsub(/[^A-Za-z0-9_\-]+/, "--"), name, tag)
        out = Pathutil.tmpdir(args, nil, root)
        out.realpath
      end

      # --

      def tmpfile(*args, root: Template.tmpdir)
        args.unshift(user, name, tag)
        Pathutil.tmpfile(
          args, nil, root
        )
      end

      # --
      # If a tag was given then it returns [self] and if a tag was not sent
      # it then goes on to detect the type and split itself accordingly
      # returning multiple, AKA all repos that should be built.
      # --
      def to_repos
        if Template.project?
          then Set.new([
            self
          ])

        else
          set = Set.new
          if @base_meta.key?("tag")
            set << self
          else
            tags.each do |tag|
              hash = Parser.from_tag_to_repo_hash(tag)
              hash = to_h.merge(hash)
              set << self.class.new(
                hash, @cli_opts
              )
            end
          end

          set
        end
      end

      # --

      def meta
        return @meta ||= begin
          Meta.new(
            @base_meta
          )
        end
      end

      # --

      def to_env(tar_gz: nil, copy_dir: nil)
        hash = meta["env"] || { "all" => {}}
        Meta.new(hash, :root => meta).merge({
          "REPO" => name,
          "TAR_GZ" => tar_gz,
          "GROUP" => meta.group,
          "DEBUG" => meta.debug?? "true" : "",
          "COPY_DIR" => copy_dir,
          "BUILD_TYPE" => type,
          "TAG" => tag
        })
      end

      # --

      rb_delegate :build, :to => :builder
      rb_delegate :alias?, :to => :meta
      rb_delegate :complex_alias?, :to => :meta
      rb_delegate :type, :to => :meta, :type => :hash
      rb_delegate :user, :to => :meta, :type => :hash
      rb_delegate :name, :to => :meta, :type => :hash
      rb_delegate :tag,  :to => :meta, :type => :hash
      rb_delegate :to_h, :to => :@base_meta
      rb_delegate :root, :to => :meta
      rb_delegate :tags, :to => :meta
      rb_delegate :clean, {
        :to => Cache, :alias_of => :cleanup, :args => %w(
          self
        )
      }
    end
  end
end
