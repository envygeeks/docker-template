# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "docker/template/common"

module Docker
  module Template
    class Rootfs < Common
      def data
        Template.get(:rootfs, {
          :rootfs_base_img => @repo.metadata["rootfs_base_img"]
        })
      end

      #

      def keep?
        @repo.metadata["keep_rootfs"]
      end

      #

      def cleanup(dir)
        return unless simple_copy?
        file = dir.join("usr/local/bin/mkimg")
        file.delete if file.exist?
      end

      #

      def unlink(img: true)
        @context.rmtree if @context&.directory?
        @img&.delete "force" => true if img && !keep? \
         rescue Docker::Error::NotFoundError
      end

      #

      private
      def setup_context
        @context = @repo.tmpdir("rootfs")
        @context.join("Dockerfile").write(data)
        @copy = @context.join(@repo.metadata["copy_dir"])
        @copy.mkdir
        copy_rootfs
      end

      #

      private
      def copy_rootfs
        return simple_rootfs_copy if simple_copy?
        dir = @repo.copy_dir("rootfs")
        Util::Copy.directory( \
          dir, @copy)
      end

      #

      private
      def simple_rootfs_copy
        file = @repo.copy_dir.join("usr/local/bin/mkimg")

        if file.file?
          Util::Copy.new(file, @copy).file
        end
      end

      #

      private
      def verify_context
        unless @copy.join("usr/local/bin/mkimg").file?
          raise Error::NoRootfsMkimg
        end
      end
    end
  end
end
