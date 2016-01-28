# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    class Builder
      attr_reader :repo
      attr_reader :context
      attr_reader :img

      # ----------------------------------------------------------------------

      COPY = [:setup_context, :copy_global, :simple_copy, :copy_all,
        :copy_type, :copy_tag, :copy_cleanup, :build_context,
          :verify_context, :cache_context].freeze

      # ----------------------------------------------------------------------

      def initialize(repo)
        @repo = repo
      end

      # ----------------------------------------------------------------------
      # Allows you to disable actions if you wish during testing or mocking.
      # ----------------------------------------------------------------------

      def testing?
        @repo.metadata["mocking"] || @repo.metadata["testing"]
      end

      # ----------------------------------------------------------------------
      # A simple copy happens when a user doesn't group up and organize their
      # copy folder because they don't need relative data.
      # ----------------------------------------------------------------------

      def simple_copy?
        @repo.copy_dir.exist? && \
          !@repo.copy_dir.join("tag").exist? && \
          !@repo.copy_dir.join("type").exist? && \
          !@repo.copy_dir.join("all").exist?
      end

      # ----------------------------------------------------------------------
      # An alias happens when the user creates a tag via aliases in opts.
      # ----------------------------------------------------------------------

      def alias?
        !@repo.complex_alias? && @repo.alias? && !rootfs?
      end

      # ----------------------------------------------------------------------

      def rootfs?
        is_a?(
          Rootfs
        )
      end

      # ----------------------------------------------------------------------

      def normal?
        @repo.type == "normal" \
          && !rootfs?
      end

      # ----------------------------------------------------------------------

      def scratch?
        @repo.type == "scratch" \
          && !rootfs?
      end

      # ----------------------------------------------------------------------
      # Pull out the repository that this repository is an alias of.
      # ----------------------------------------------------------------------

      def parent_repo
        return @parent_repo if @parent_repo
        Repo.new(@repo.to_h.merge({
          "tag" => @repo.metadata.aliased
        }))
      end

      # ----------------------------------------------------------------------
      # Pull out the image that this repository is aliasing if it's an alias.
      # ----------------------------------------------------------------------

      def parent_img
        return unless alias?
        @parent_img ||= Docker::Image.get(
          parent_repo.to_s
        )

      rescue Docker::Error::NotFoundError
        if alias?
          nil
        end
      end

      # ----------------------------------------------------------------------
      # Push an image up to Dockerhub or another provider after building.
      # ----------------------------------------------------------------------

      def push
        return if rootfs? || !@repo.pushable?
        Utils::Notify.push(self)

        auth! unless testing?
        logger = Logger.new.method(:api)
        img = @img || Docker::Image.get(@repo.to_s)
        img.push(&logger) unless testing?
      end

      # ----------------------------------------------------------------------
      # Copy, prebuild, verify and then finally build the image.
      # ----------------------------------------------------------------------

      def build
        Simple::Ansi.clear
        return build_alias if alias?
        Utils::Notify.build(@repo, rootfs: rootfs?)
        copy_prebuild_and_verify
        chdir_build

      rescue SystemExit => exit_
        unlink :img => true
        raise exit_
      ensure
        if !rootfs?
          unlink else unlink({
            :img => false
          })
        end
      end

      # ----------------------------------------------------------------------
      # This method is a default reference.  It is called when when the
      # image is done building or when there is an error and we need to clean
      # up some stuff before exiting, use it... please.
      # ----------------------------------------------------------------------

      def unlink(*_)
        $stdout.puts Ansi.red(
          "#{__method__}: Not Implemented."
        )
      end

      # ----------------------------------------------------------------------

      private
      def build_alias
        self.class.new(parent_repo).build unless parent_img
        parent_img.tag(@repo.to_tag_h)
        Utils::Notify.alias(self)
        push
      end

      # ----------------------------------------------------------------------
      # The prebuild happens when a user has "build_context", which
      # typically only happens with scratch, which will prebuild it's rootfs
      # image so it can get to building it's actual image.
      # ----------------------------------------------------------------------

      private
      def copy_prebuild_and_verify
        unless respond_to?(:setup_context, true)
          raise Error::NoSetupContext
        end

        COPY.map do |val|
          if respond_to?(val, true)
            send(val)
          end
        end
      end

      # ----------------------------------------------------------------------
      # Chdir to the context directory and build the image (or context.)
      # ----------------------------------------------------------------------

      private
      def chdir_build
        @context.chdir do
          opts = { :t => @repo.to_s(rootfs: rootfs?) }
          $stderr.puts Simple::Ansi.yellow("TTY not supported: Ignored.") if @repo.metadata["tty"]
          @img = Docker::Image.build_from_dir(".", opts, &Logger.new(self).method(:api))
          push
        end
      end

      # ----------------------------------------------------------------------
      # A default method that disables caching and informs the user as such.
      # This method is a default reference: DO NOT REFERENCE SUPER.
      # ----------------------------------------------------------------------

      private
      def cache_context
        if repo.syncable?
          $stderr.puts Simple::Ansi.red("Context syncing not supported")
        end
      end

      # ----------------------------------------------------------------------
      # The root can have it's own global copy directory shared across
      # all repositories in your repo container directory so this encapsulates
      # those. <root>/copy
      # ----------------------------------------------------------------------

      private
      def copy_global
        return if rootfs? || Template.repo_is_root?
        dir = Template.root.join(
          @repo.metadata["copy_dir"]
        )

        if dir.exist?
          then dir.safe_copy(
            @copy, :root => Template.root
          )
        end
      end

      # ----------------------------------------------------------------------
      # When you have no tag, type, all, this is called a simple
      # copy, and we will skip caring about the other types of copies and
      # just do a direct copy of the copy root.
      # <root>/<repo>/copy
      # ----------------------------------------------------------------------

      private
      def simple_copy
        return unless simple_copy?
        dir = @repo.copy_dir

        if dir.exist?
          then dir.safe_copy(
            @copy, :root => Template.root
          )
        end
      end

      # ----------------------------------------------------------------------
      # <root>/<repo>/copy/tag/<tag> where tag is the container for
      # holding data for specific tags, so that if a specific tag needs
      # specific data it doesn't need to share it globally.
      # *Not used with simple copy*
      # ----------------------------------------------------------------------

      private
      def copy_tag
        return if rootfs? || simple_copy?
        dir = @repo.copy_dir("tag", @repo.tag)

        if dir.exist?
          then dir.safe_copy(
            @copy, :root => Template.root
          )
        end
      end

      # ----------------------------------------------------------------------
      # <root>/<repo>/copy/type/<type> where type is defined as
      # the value in the tags key of your opts.yml, types are like a
      # set of tags that share common data.
      # *Not used with simple copy*
      # ----------------------------------------------------------------------

      private
      def copy_type
        build_type = @repo.metadata["tags"][@repo.tag]
        return if rootfs? || simple_copy? || !build_type
        dir = @repo.copy_dir("type", build_type)

        if dir.exist?
          then dir.safe_copy(
            @copy, :root => Template.root
          )
        end
      end

      # ----------------------------------------------------------------------
      # <root>/<repo>/copy/all where it is shared local-globally in the
      # current repo, but not across all the other repos.
      # *Not used with simple copy*
      # ----------------------------------------------------------------------

      private
      def copy_all
        return if rootfs? || simple_copy?
        dir = @repo.copy_dir("all")

        if dir.exist?
          then dir.safe_copy(
            @copy, :root => Template.root
          )
        end
      end

      # ----------------------------------------------------------------------
      # Read the credentials file for Docker and authenticate to push images.
      # ----------------------------------------------------------------------

      private
      def auth!
        credentials = Pathutil.new("~/.docker/config.json").expand_path.read_json
        return if credentials.empty?

        credentials["auths"].each do |server, info|
          user, pass = Base64.decode64(info["auth"]).split(
            ":", 2
          )

          Docker.authenticate!({
            "username" => user,
            "serveraddress" => server,
            "email" => info["email"],
            "password" => pass
          })
        end
      end
    end
  end
end
