# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class Scratch < Builder
      attr_reader :rootfs

      # Caches and builds the master rootfs for repos, this is cached
      # on the class because it could be used many times in a single build
      # so we make sure to keep it around so you don't have tons of
      # replication going about slowing down all of the builds.

      def self.rootfs_for(repo)
        (@rootfs ||= {})[repo.name] ||= begin
          Rootfs.new(repo).tap(&:build)
        end
      end

      #

      def data
        Template.get(:scratch, {
          :maintainer => @repo.metadata["maintainer"],
          :entrypoint => @repo.metadata["entry"].fallback,
          :tar_gz => @tar_gz.basename
        })
      end

      #

      def unlink(img: false)
        @copy.rmtree if @copy&.directory?
        @img&.delete "force" => true if img
        @context.rmtree if @context&.directory?
        @tar_gz.unlink if @tar_gz&.file?
      end

      #

      private
      def setup_context
        @context = @repo.tmpdir
        @tar_gz = @repo.tmpfile "archive", ".tar.gz", root: @context
        @copy = @repo.tmpdir "copy"
        copy_dockerfile
      end

      #

      private
      def copy_dockerfile
        data = self.data % @tar_gz.basename
        dockerfile = @context.join("Dockerfile")
        dockerfile.write(data)
      end

      #

      def copy_cleanup
        @rootfs ||= self.class.rootfs_for(@repo)
        @rootfs.cleanup(@copy)
      end

      #

      def verify_context
        unless @tar_gz.size > 0
          raise Error::InvalidTargzFile, @tar_gz
        end
      end

      #

      private
      def build_context
        @rootfs ||= self.class.rootfs_for(@repo)

        img = Container.create(create_args)
        logger = @repo.metadata["tty"] ? Loggers::TTY : Loggers::Simple
        logger_opts = { :tty => @repo.metadata["tty"], :stdout => true, :stderr => true }
        img.start(start_args).attach(logger_opts, &logger.new.method(:log))
        status = img.json["State"]["ExitCode"]

        if status != 0
          raise Error::BadExitStatus, status
        end
      ensure
        img&.tap(&:stop)&.delete({
          "force" => true
        })
      end

      #

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

      #

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
