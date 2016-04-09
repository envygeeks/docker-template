# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    class Builder
      extend Forwardable::Extended

      # ----------------------------------------------------------------------

      attr_reader :repo
      attr_reader :context
      attr_reader :img

      # ----------------------------------------------------------------------

      SETUP = [:setup_context, :copy_global, :copy_all,
        :copy_group, :copy_tag, :copy_cleanup, :build_context,
          :verify_context, :cache_context].freeze

      # ----------------------------------------------------------------------

      def initialize(repo)
        @repo = repo
      end

      # ----------------------------------------------------------------------
      # Checks to see if this repository is an alias. This happens when the
      # user has alised data inside of their configuration file.  At this point
      # we will not only copy the parent's data but the aliased data.
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

      def aliased_img
        return unless alias?
        @aliased_img ||= Docker::Image.get(
          aliased_repo.to_s
        )

      rescue Docker::Error::NotFoundError
        if alias?
          nil
        end
      end

      # ----------------------------------------------------------------------

      def push
        return if rootfs? || !@repo.pushable?
        Notify.push self
        auth!

        img = @img || Image.get(@repo.to_s)
        img.push nil, :repo_tag => \
          @repo.to_s, &Logger.new.method(:api)

      rescue Docker::Error::NotFoundError
        $stderr.puts Simple::Ansi.red(
          "Image does not exist, unpushable."
        )
      end

      # ----------------------------------------------------------------------

      def build
        Simple::Ansi.clear if @repo.buildable?
        return build_alias if alias?
        setup

        if @repo.buildable?
          Notify.build(@repo, {
            :rootfs => rootfs?
          })

          chdir_build
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

      # ----------------------------------------------------------------------
      # This method is a default reference.  It is called when the image is
      # done building or when there is an error and we need to clean up some
      # stuff before exiting, use it... please.
      # ----------------------------------------------------------------------

      def teardown(*_)
        $stderr.puts Ansi.red(
          "#{__method__}: Not Implemented."
        )
      end

      # ----------------------------------------------------------------------

      private
      def build_alias
        if @repo.buildable?
          aliased = self.class.new(aliased_repo)
          aliased.build unless aliased_img
          Notify.alias(
            self
          )

          aliased_img.tag(
            @repo.to_tag_h
          )
        end

        push
      end

      # ----------------------------------------------------------------------
      # The prebuild happens when a user has "setup_context", which typically
      # only happens with scratch, which will prebuild it's rootfs image so
      # it can get to building it's actual image.
      # ----------------------------------------------------------------------

      private
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

      # ----------------------------------------------------------------------

      private
      def chdir_build
        @context.chdir do
          logger = Logger.new(self).method(:api)
          opts = { :t => @repo.to_s(rootfs: rootfs?) }
          $stderr.puts Simple::Ansi.yellow("TTY not supported: Ignored.") if @repo.metadata["tty"]
          @img = Docker::Image.build_from_dir(".", opts, &logger)
        end
      end

      # ----------------------------------------------------------------------

      private
      def cache_context
        if repo.syncable?
          $stderr.puts Simple::Ansi.red(
            "Context syncing not supported"
          )
        end
      end

      # ----------------------------------------------------------------------
      # The root can have it's own global copy directory shared across all
      # repos in your repo container dir so this encapsulates those.
      # ----------------------------------------------------------------------

      private
      def copy_global
        unless rootfs?
          dir = Template.root.join(
            @repo.metadata["copy_dir"]
          )

          if dir.exist?
            then dir.safe_copy(
              @copy, :root => Template.root
            )
          end
        end
      end

      # ----------------------------------------------------------------------

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

      # ----------------------------------------------------------------------

      private
      def copy_group
        build_group = @repo.metadata["tags"][
          @repo.tag
        ]

        if ENV["enable-pry"]
          require "pry"
          Pry.output = STDOUT
          binding.pry
        end

        unless rootfs? || !build_group
          dir = @repo.copy_dir("group", build_group)

          if dir.exist?
            then dir.safe_copy(
              @copy, :root => Template.root
            )
          end
        end
      end

      # ----------------------------------------------------------------------

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

      # ----------------------------------------------------------------------

      rb_delegate :aliased_repo, {
        :to => :repo, :alias_of => :aliased
      }
    end
  end
end
