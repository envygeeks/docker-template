module Docker
  module Template
    class Alias
      def initialize(aliased)
        @aliased = aliased
      end

      #

      def build
        Util.notify_alias(@aliased)
        prebuild unless @aliased.parent_img
        @aliased.parent_img.tag(@aliased.repo.to_tag_h)
        @aliased.push
      end

      #

      private
      def prebuild
        repo   = @aliased.parent_repo
        normal = @aliased.repo.type == "normal"
        @aliased.class.new(repo, @aliased.rootfs_img) unless normal
        @aliased.class.new(repo).build if normal
      end
    end
  end
end
