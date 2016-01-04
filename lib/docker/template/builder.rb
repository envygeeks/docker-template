# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "docker/template/loggers/stream"
require "docker/template/alias"

module Docker
  module Template
    class Builder
      attr_reader :repo
      attr_reader :context
      attr_reader :img

      include Hooks::Methods
      def self.inherited(klass)
        klass.register_hook_point(*COPY, :build, :push)
      end

      #

      COPY = %W(setup_context copy_global simple_copy copy_all copy_type copy_tag
        copy_cleanup build_context verify_context cache_context).freeze
      register_hook_point(*COPY, :build, :push)
      register_hook_point(:auth)

      #

      def initialize(repo)
        @repo = repo
      end

      #

      def simple_copy?
        @repo.copy_dir.exist? && \
          !@repo.copy_dir.join("tag").exist? && \
          !@repo.copy_dir.join("type").exist? && \
          !@repo.copy_dir.join("all").exist?
      end

      #

      def alias?
        !@repo.complex_alias? && @repo.alias? && !rootfs?
      end

      #

      def rootfs?
        is_a?(Rootfs)
      end

      #

      [:normal, :scratch].each do |sym|
        define_method("#{sym}?") do
          @repo.type == sym.to_s && !rootfs?
        end
      end

      #

      def parent_repo
        return @parent_repo if @parent_repo
        Repo.new(@repo.to_h.merge({
          "tag" => @repo.metadata.aliased
        }))
      end

      #

      def parent_img
        return unless alias?
        @parent_img ||= Docker::Image.get(parent_repo.to_s)
      rescue Docker::Error::NotFoundError
        if alias?
          nil
        end
      end

      #

      def push
        return if rootfs? || !@repo.pushable?

        auth!
        img = @img || Docker::Image.get(@repo.to_s)
        logger = Loggers::Stream.new.method(:log)
        img.push(&logger)
        run_hooks :push
      end

      #

      def build
        return Alias.new(self).build if alias?

        Simple::Ansi.clear
        Utils.notify_build(@repo, rootfs: rootfs?)
        copy_prebuild_and_verify
        chdir_build

        run_hooks :build
      rescue SystemExit => exit_
        unlink img: true
        raise exit_
      ensure
        if rootfs?
          unlink img: false else unlink
        end
      end

      # The prebuild happens when a user has "build_context", which
      # typically only happens with scratch, which will prebuild it's rootfs
      # image so it can get to building it's actual image.

      private
      def copy_prebuild_and_verify
        raise Error::NoSetupContext unless respond_to?(:setup_context, true)

        COPY.map do |val|
          send(val) if respond_to?(val, true)
        end
      end

      #

      private
      def chdir_build
        Dir.chdir(@context) do
          @img = Docker::Image.build_from_dir(".", &Loggers::Stream.new.method(:log))
          @img.tag rootfs?? @repo.to_rootfs_h : @repo.to_tag_h
          push
        end
      end

      #

      private
      def cache_context
        if repo.syncable?
          $stderr.puts Simple::Ansi.red("Context caching not supported")
        end
      end

      # The root can have it's own global copy directory shared
      # across all repositories in your repo container directory so
      # this encapsulates those.
      # <root>/copy

      private
      def copy_global
        return if rootfs? || Template.repo_is_root?
        dir = Template.root.join(@repo.metadata["copy_dir"])
        Utils::Copy.directory(dir, @copy)
        run_hooks :copy_global, dir
      end

      # When you have no tag, type, all, this is called a simple
      # copy, and we will skip caring about the other types of copies and
      # just do a direct copy of the copy root.
      # <root>/<repo>/copy

      private
      def simple_copy
        return unless simple_copy?

        dir = @repo.copy_dir
        Utils::Copy.directory(dir, @copy)
        run_hooks :simple_copy, dir
      end

      # <root>/<repo>/copy/tag/<tag> where tag is the container for
      # holding data for specific tags, so that if a specific tag needs
      # specific data it doesn't need to share it globally.
      # *Not used with simple copy*

      private
      def copy_tag
        return if rootfs? || simple_copy?
        dir = @repo.copy_dir("tag", @repo.tag)
        Utils::Copy.directory(dir, @copy)
        run_hooks :copy_tag, dir
      end

      # <root>/<repo>/copy/type/<type> where type is defined as
      # the value in the tags key of your opts.yml, types are like a
      # set of tags that share common data.
      # *Not used with simple copy*

      private
      def copy_type
        build_type = @repo.metadata["tags"][@repo.tag]
        return if rootfs? || simple_copy? || !build_type
        dir = @repo.copy_dir("type", build_type)
        Utils::Copy.directory(dir, @copy)
        run_hooks :copy_type, dir
      end

      # <root>/<repo>/copy/all where it is shared local-globally in the
      # current repo, but not across all the other repos.
      # *Not used with simple copy*

      private
      def copy_all
        return if rootfs? || simple_copy?
        dir = @repo.copy_dir("all")
        Utils::Copy.directory(dir, @copy)
        run_hooks :copy_all, dir
      end

      #

      private
      def auth!
        if !any_hooks?(:auth)
          credentials = Pathname.new("~/.docker/config.json").expand_path
          credentials = JSON.parse(credentials.read) if credentials.exist?
          return unless credentials

          credentials.fetch("auths").each do |server, info|
            user, pass = Base64.decode64(info["auth"]).split(":", 2)
            Docker.authenticate!({
              "username" => user,
              "serveraddress" => server,
              "email" => info["email"],
              "password" => pass
            })
          end
        else
          run_hooks :auth
        end
      end
    end
  end
end
