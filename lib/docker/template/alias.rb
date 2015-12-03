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
        simple = @aliased.repo.type == "simple"
        @aliased.class.new(repo, @aliased.rootfs_img) unless simple
        @aliased.class.new(repo).build if simple
      end
    end
  end
end
