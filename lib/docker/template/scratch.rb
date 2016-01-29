# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    class Scratch < Builder
      attr_reader :rootfs

      # ----------------------------------------------------------------------
      # Stores and caches Rootfs images across multiple builds so if many
      # imges use the same image they don't have to constantly rebuild causing
      # an extreme inefficiency in the build system.
      # ----------------------------------------------------------------------

      def self.rootfs_for(repo)
        (@rootfs ||= {})[repo.name] ||= begin
          Rootfs.new(repo).tap(&:build)
        end
      end

      # ----------------------------------------------------------------------

      def self.cleanup
        @rootfs.each do |key, val|
          val.unlink({
            :img => true
          })
        end
      end

      # ----------------------------------------------------------------------
      # Pull and parse with ERB the Rootfs Docker template.
      # ----------------------------------------------------------------------

      def data
        Template.get(:scratch, {
          :maintainer => @repo.metadata["maintainer"],
          :entrypoint => @repo.metadata["entry"].fallback,
          :tar_gz => @tar_gz.basename
        })
      end

      # ----------------------------------------------------------------------

      def unlink(img: false)
        @copy.rm_rf if @copy
        @context.rm_rf if @context
        @tar_gz.rm_rf if @tar_gz

        if @img && img
          then @img.delete({
            "force" => true
          })
        end
      rescue Docker::Error::NotFoundError
        nil
      end

      # ----------------------------------------------------------------------

      private
      def setup_context
        @context = @repo.tmpdir
        @tar_gz = @repo.tmpfile "archive", ".tar.gz", root: @context
        @copy = @repo.tmpdir "copy"
        copy_dockerfile
      end

      # ----------------------------------------------------------------------
      # Copy the Dockerfile into the current context.
      # ----------------------------------------------------------------------

      private
      def copy_dockerfile
        data = self.data % @tar_gz.basename
        dockerfile = @context.join("Dockerfile")
        dockerfile.write(data)
      end

      # ----------------------------------------------------------------------
      # This taps into the Rootfs image to ask it to cleanup it's stuff.
      # ----------------------------------------------------------------------

      def copy_cleanup
        self.class.rootfs_for(@repo).cleanup(
          @copy
        )
      end

      # ----------------------------------------------------------------------

      def verify_context
        if @tar_gz.zero?
          raise Error::InvalidTargzFile, @tar_gz
        end
      end

      # ----------------------------------------------------------------------

      private
      def build_context
        @rootfs ||= self.class.rootfs_for(@repo)

        img = Container.create(create_args)
        img.start(start_args).attach(logger_opts, &Logger.new.method(logger_type))
        status = img.json["State"]["ExitCode"]

        if status != 0
          raise Error::BadExitStatus, status
        end
      ensure
        if img
          then img.tap(&:stop).delete({
            "force" => true
          })
        end
      end

      # ----------------------------------------------------------------------

      private
      def logger_type
        @repo.metadata["tty"] ? :tty : :simple
      end

      # ----------------------------------------------------------------------

      private
      def logger_opts
        return {
          :tty => @repo.metadata["tty"], :stdout => true, :stderr => true
        }
      end

      # ----------------------------------------------------------------------
      # Create args are the arguments we use on Docker::Container.create.
      # You'll notice that we have a volumes key, this key is only part of the
      # shit that Docker puts us through, @see `#start_args`.
      # ----------------------------------------------------------------------

      private
      def create_args
        {
          "Tty"     => @repo.metadata["tty"],
          "Env"     => @repo.to_env(tar_gz: @tar_gz, copy_dir: @copy).to_env_ary,
          "Name"    => ["rootfs", @repo.name, @repo.tag, "image"].join("-"),
          "Image"   => @rootfs.img.id,
          "Volumes" => {
            @tar_gz.to_s => {}, @copy.to_s => {}
          }
        }
      end

      # ----------------------------------------------------------------------
      # Arguments used when doing Docker::Container#start.  This completes
      # the volumes by binding them to the Docker instance.
      # ----------------------------------------------------------------------

      private
      def start_args
        {
          "Binds" => [
            "#{@copy}:#{@copy}:ro", "#{@tar_gz}:#{@tar_gz}"
          ]
        }
      end
    end
  end
end
