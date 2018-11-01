# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class Builder
      extend Forwardable::Extended

      # --

      attr_reader :repo
      attr_reader :context
      attr_reader :copy
      attr_reader :img

      # --

      ALIAS_SETUP = [:cache_context]
      SETUP = [:setup_context, :copy_global, :copy_project,
        :copy_all, :copy_group, :copy_tag, :copy_cleanup, :copy_git, :build_context,
          :verify_context, :cache_context].freeze

      # --

      def initialize(repo)
        @repo = repo
      end

      # --
      # Checks to see if this repository is an alias. This happens when the
      # user has alised data inside of their configuration file.  At this point
      # we will not only copy the parent's data but the aliased data.
      # --

      def alias?
        !@repo.complex_alias? && @repo.alias? && !rootfs?
      end

      # --

      def rootfs?
        is_a?(
          Rootfs
        )
      end

      # --

      def normal?
        @repo.type == "normal" \
          && !rootfs?
      end

      # --

      def scratch?
        @repo.type == "scratch" \
          && !rootfs?
      end

      # --

      def aliased_img
        if alias?
          then @aliased_img ||= begin
            Docker::Image.get(
              aliased_repo ? aliased_repo.to_s : aliased_tag
            )
          end
        end

      rescue Docker::Error::NotFoundError
        if alias?
          nil
        end
      end

      # --

      def push
        return if rootfs? || !@repo.pushable?

        Notify.push(self)
        Auth.new(@repo).auth
        img = @img || Image.get(@repo.to_s)
        img.push nil, :repo_tag => @repo.to_s, \
          &Logger.new(repo).method(:api)

      rescue Docker::Error::NotFoundError
        $stderr.puts Simple::Ansi.red(
          "Image does not exist, unpushable."
        )
      end

      # --

      def build
        Simple::Ansi.clear if @repo.buildable?
        return build_alias if alias?
        setup

        if @repo.buildable?
          then Notify.build(@repo, :rootfs => rootfs?) do
            chdir_build
          end
        end

        push
      rescue SystemExit => exit_
        teardown :img => true
        raise exit_
      ensure
        if !rootfs?
          teardown else teardown({
            :img => false
          })
        end
      end

      # --
      # This method is a default reference.  It is called when the image is
      # done building or when there is an error and we need to clean up some
      # stuff before exiting, use it... please.
      # --

      def teardown(*_)
        $stderr.puts Ansi.red(
          "#{__method__}: Not Implemented."
        )
      end

      # --
      # The prebuild happens when a user has "setup_context", which typically
      # only happens with scratch, which will prebuild it's rootfs image so
      # it can get to building it's actual image.
      # --

      def setup
        unless respond_to?(:setup_context, true)
          raise Error::NoSetupContext
        end

        SETUP.map do |val|
          if respond_to?(val, true)
            send(val)
          end
        end
      end

      # --

      private
      def build_alias
        alias_setup

        if @repo.buildable?
          if (repo = aliased_repo)
            aliased = self.class.new(repo)
            unless aliased_img
              aliased.build
            end

          elsif !aliased_img
            raise(
              Error::ImageNotFound, aliased_tag
            )
          end

          Notify.alias(self)
          aliased_img.tag(
            @repo.to_tag_h
          )
        end

        push
      end

      # --

      private
      def alias_setup
        ALIAS_SETUP.map do |m|
          if respond_to?(m, true)
            send(m)
          end
        end
      end

      # --

      private
      def chdir_build
        @context.chdir do
          logger = Logger.new(repo).method(:api)
          opts = {
            :force => @repo.meta.force?,
            :t => @repo.to_s(rootfs: rootfs?),
            :squash => @repo.meta.squash?,
            :nocache => @repo.meta.force?
          }

          if @repo.meta["tty"]
            $stderr.puts Simple::Ansi.yellow(
              "TTY not supported: Ignored."
            )
          end

          @img = Docker::Image.build_from_dir(".",
            opts, &logger
          )
        end
      end

      # --

      private
      def cache_context
        if repo.cacheable?
          $stderr.puts Simple::Ansi.red(
            "Context caching not supported"
          )
        end
      end

      # --
      # Copy any git repositories the user wishes us to copy.
      # --

      private
      def copy_git
        return if rootfs? || !@repo.meta.git? || @repo.meta.push_only?
        require "rugged"

        repos = @repo.meta[:git]
        repos = repos.for_all + (repos.by_tag || []) +
          (repos.by_type || [])

        repos.each do |repo|
          credentials = Rugged::Credentials::SshKey.new({
            :privatekey => Pathutil.new(repo[:key]).expand_path.to_s,
             :publickey => Pathutil.new(repo[:pub]).expand_path.to_s,
             :username => repo[:user]
          })

          dir = @copy.join(repo[:clone_to])
          if !dir.exist?
            $stderr.puts Simple::Ansi.green("Cloning #{repo[:repo]} to #{repo[:clone_to]}.")
            Rugged::Repository.clone_at(repo[:repo], dir.to_s, {
              :credentials => credentials
            })
          else
            $stderr.puts Simple::Ansi.yellow(
              "Skipping #{repo[:repo]}, exists already."
            )
          end
        end
      end

      # --
      # The root can have it's own global copy directory shared across all
      # repos in your repo container dir so this encapsulates those.
      # --

      private
      def copy_global
        unless rootfs?
          dir = Template.root.join(
            @repo.meta["copy_dir"]
          )

          if dir.exist?
            then dir.safe_copy(
              @copy, :root => Template.root
            )
          end
        end
      end

      # --

      private
      def copy_project
        if Template.project?
          ignores = repo.meta["project_copy_ignore"].map do |path|
            Pathutil.new(path).expand_path(
              Template.root
            )
          end

          Template.root.safe_copy(
            context.join(repo.meta.project_copy_dir), {
              :root => Template.root, :ignore => ignores
            }
          )
        end
      end

      # --

      private
      def copy_tag
        unless rootfs?
          dir = @repo.copy_dir("tag", @repo.tag)

          if dir.exist?
            then dir.safe_copy(
              @copy, :root => Template.root
            )
          end
        end
      end

      # --

      private
      def copy_group
        build_group = @repo.meta["tags"][
          @repo.tag
        ]

        unless rootfs? || !build_group
          dir = @repo.copy_dir("group", build_group)

          if dir.exist?
            then dir.safe_copy(
              @copy, :root => Template.root
            )
          end
        end
      end

      # --

      private
      def copy_all
        unless rootfs?
          dir = @repo.copy_dir("all")

          if dir.exist?
            then dir.safe_copy(
              @copy, :root => Template.root
            )
          end
        end
      end

      # --

      rb_delegate :aliased_tag, :to => "repo.meta"
      rb_delegate :aliased_repo, {
        :to => :repo, :alias_of => :aliased
      }

      class << self

        # --
        # REFERENCE METHOD: This is here to let you know we access files.
        # --

        def files
          return [
            #
          ]
        end

        # --

        def projects_allowed!
          return @projects_allowed \
            = true
        end

        # --

        def projects_allowed?
          return !!@projects_allowed
        end

        # --

        def sub?
          false
        end

        # --

        def inherited(klass)
          (@sub_classes ||= []).push(
            klass
          )
        end

        # --

        def all
          @sub_classes ||= [
            #
          ]
        end
      end
    end
  end
end

require "docker/template/builder/rootfs"
require "docker/template/builder/scratch"
require "docker/template/builder/normal"
