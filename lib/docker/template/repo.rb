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

      route_to_hash :name, :@base_metadata, :repo
      route_to_hash [:tag, :type, :user], :metadata
      def_delegator :@base_metadata, :to_h
      def_delegator :metadata, :aliased
      def_delegator :metadata, :tags

      def initialize(base_metadata)
        raise ArgumentError, "Metadata not a hash" if !base_metadata.is_a?(Hash)

        @base_metadata = base_metadata.freeze
        @sync_allowed  = type == "simple" ? true : false
        raise Error::InvalidRepoType, type if !Template.config.build_types.include?(type)
        raise Error::RepoNotFound, name if !root.exist?
      end

      def builder
        const = Template.const_get(type.capitalize)
        const.new(self)
      end

      # Simply initializes the the builder and passes itself onto
      # it so that it the builder can take over and do it's job cleanly
      # without us needing to care about what's going on.

      def build
        return builder.build
      end

      #

      def disable_sync!
        @sync_allowed = false
      end

      #

      def syncable?
        metadata["dockerhub_copy"] && @sync_allowed
      end

      #

      def to_s
        "#{user}/#{name}:#{tag}"
      end

      #

      def copy_dir(*path)
        dir = metadata["copy_dir"]
        root.join(dir, *path)
      end

      #

      def building_all?
       !@base_metadata.has_key?("tag")
      end

      #

      def to_rootfs_s
        prefix = metadata["local_prefix"]
        "#{prefix}/rootfs:#{name}"
      end

      #

      def root
        return @root ||= begin
          Template.repo_root_for(name)
        end
      end

      #

      def to_tag_h
        {
          "force" => true,
           "repo" => "#{user}/#{name}",
            "tag" => tag,
        }
      end

      #

      def to_rootfs_h
        prefix = metadata["local_prefix"]

        {
          "force" => true,
           "repo" => "#{prefix}/rootfs",
            "tag" => name
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
          base, set = to_h, Set.new
          tags.each do |tag|
            set.add(self.class.new(base.merge({
              "tag" => tag
            })))
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
        return @metadata ||= begin
          metadata = Template.repo_root_for(name)
          metadata = Template.config.read_config_from(metadata)
          Metadata.new(metadata).merge(@base_metadata)
        end
      end

      #

      def to_env_hash(tar_gz: nil, copy_dir: nil)
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
          "TAG" => tag,
        }).to_env
      end
    end
  end
end
