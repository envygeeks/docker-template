# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class Rootfs < Common
      attr_reader :img
      def initialize(repo)
        @repo = repo
      end

      #

      def data
        Template.get(:rootfs, {
          :rootfs_base_img => @repo.metadata["rootfs_base_img"]
        })
      end

      # In a typical situation we do not remove the rootfs img and don't
      # recommend removing it as it's better cached by Docker, if you wish
      # to delete it we will.  Now, here we only remove it if we get told
      # to exit, since we will be in the middle of a build and probably
      # not have tagged yet, unless we are downstream, we will remove
      # it so you have no broken images on your system.

      def unlink(img: true)
        keep = @repo.metadata["keep_rootfs"]
        @img.delete "force" => true if img && @img && !keep
        @context.rmtree if @context && @context.directory?
      rescue Docker::Error::NotFoundError
        nil
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
        dir = @repo.copy_dir("rootfs")
        Util::Copy.new(dir, @copy).directory
      rescue Errno::ENOENT => error_
        if error_.message !~ /\/(copy|rootfs)\Z/
          raise error_ else raise Error::NoRootfsCopyDir
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
