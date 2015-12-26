# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template

    # * A repo is not an image but a parent name w/ a tag.
    # * An image is the final result of a build on a repo, and is associated.
    # * Think of an image as the binary of the source in the repo.

    class Repo
      extend Forwardable, Routable

      def_delegator :builder, :build
      def_delegator :metadata, :complex_alias?
      route_to_hash [:tag, :type, :user, :name], :metadata
      def_delegator :@base_metadata, :to_h
      def_delegator :metadata, :alias?
      def_delegator :metadata, :tags

      def initialize(base_metadata = {})
        raise ArgumentError, "Metadata not a hash" unless base_metadata.is_a?(Hash)

        @base_metadata = base_metadata.freeze
        @sync_allowed  = type == "normal" ? true : false
        raise Error::InvalidRepoType, type unless Template.config.build_types.include?(type)
        raise Error::RepoNotFound, name unless root.exist?
      end

      def builder
        const = Template.const_get(type.capitalize)
        const.new(self)
      end

      #

      def disable_sync!
        @sync_allowed = false
      end

      #

      def syncable?
        metadata["dockerhub_cache"] && @sync_allowed
      end

      #

      def to_s(type = nil)
        type ||= :image

        if type == :image
          "#{user}/#{name}:#{tag}"
        else
          prefix = metadata["local_prefix"]
          "#{prefix}/rootfs:#{name}"
        end
      end

      #

      def copy_dir(*path)
        dir = metadata["copy_dir"]
        root.join(dir, *path)
      end

      #

      def building_all?
        !@base_metadata.key?("tag")
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
        prefix = metadata["local_prefix"]

        {
          "tag"   => name,
          "repo"  => "#{prefix}/rootfs",
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
        ext = prefixes.pop if prefixes.last =~ /\A\./
        prefixes = ["#{prefixes.join("-")}-"]
        prefixes = ext ? prefixes.push(ext) : prefixes.first
        args = [prefixes, root].delete_if(&:nil?)
        Pathname.new(Tempfile.new(*args))
      end

      # If a tag was given then it returns [self] and if a tag was not
      # sent it then goes on to detect the type and split itself accordingly
      # returning multiple AKA all repos to be built.

      def to_repos
        if building_all?
          set  = Set.new
          base = to_h

          tags.each do |tag|
            base = base.merge("tag" => tag)
            set << self.class.new(base)
          end

          set
        else
          Set.new([
            self
          ])
        end
      end

      #

      def metadata
        @metadata ||= begin
          metadata = Template.repo_root_for(@base_metadata["repo"])
          metadata = Template.config.read_config_from(metadata)
          Metadata.new(metadata).merge_base_metadata(@base_metadata)
        end
      end

      #

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
