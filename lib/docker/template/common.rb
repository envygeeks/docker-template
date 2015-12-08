# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class Common
      CopyMethods = [
        :setup_context, :copy_global,
        :copy_all, :copy_type, :copy_tag, :build_context,
        :verify_context].freeze

      def push
        return if rootfs? || !Interface.push?

        Auth.auth!
        img = @img || Docker::Image.get(@repo.to_s)
        logger = Stream.new.method(:log)
        img.push(&logger)
      end

      #

      def aliased?
        @repo.tag != @repo.aliased && !rootfs?
      end

      #

      def rootfs?
        false
      end

      #

      def parent_repo
        return false unless aliased?
        @parent_repo ||= begin
          Repo.new(@repo.to_h.merge("tag" => @repo.aliased))
        end
      end

      #

      def parent_img
        return false unless aliased?
        @parent_img ||= Docker::Image.get(parent_repo.to_s)
      rescue Docker::Error::NotFoundError
        if aliased?
          nil
        end
      end

      #

      def build
        return Alias.new(self).build if aliased?

        Ansi.clear
        Util.notify_build(@repo, rootfs: rootfs?)
        copy_build_and_verify
        chdir_build
      rescue SystemExit => exit_
        unlink img: true
        raise exit_
      ensure
        if rootfs?
          unlink img: false else unlink
        end
      end

      #

      def chdir_build
        Dir.chdir(@context) do
          @img = Docker::Image.build_from_dir(".", &Stream.new.method(:log))
          @img.tag rootfs?? @repo.to_rootfs_h : @repo.to_tag_h
          push
        end
      end

      #

      private
      def copy_build_and_verify
        unless respond_to?(:setup_context, true)
          raise Error::NoSetupContextFound
        end

        CopyMethods.each do |val|
          send(val) if respond_to?(val, true)
        end
      end

      private
      def copy_tag
        return if rootfs?
        dir = @repo.copy_dir("tag", @repo.tag)
        Util::Copy.directory(dir, @copy)
      end

      #

      private
      def copy_global
        return if rootfs? || Template.repo_is_root?
        dir = Template.root.join(@repo.metadata["copy_dir"])
        Util::Copy.directory(dir, @copy)
      end

      #

      private
      def copy_type
        return unless !rootfs? && build_type = @repo.metadata["tags"][@repo.tag]
        dir = @repo.copy_dir("type", build_type)
        Util::Copy.directory(dir, @copy)
      end

      #

      private
      def copy_all
        return if rootfs?
        dir = @repo.copy_dir("all")
        Util::Copy.directory(dir, @copy)
      end
    end
  end
end
