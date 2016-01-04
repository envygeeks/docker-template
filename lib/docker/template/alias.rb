# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class Alias
      extend Forwardable
      def_delegator :@aliased, :normal?

      def initialize(aliased)
        @aliased = aliased
      end

      #

      def build
        Utils.notify_alias(@aliased)
        prebuild unless @aliased.parent_img
        @aliased.parent_img.tag(@aliased.repo.to_tag_h)
        @aliased.push
      end

      #

      private
      def prebuild
        repo = @aliased.parent_repo
        @aliased.class.new(repo, @aliased.rootfs_img) unless normal?
        @aliased.class.new(repo).build if normal?
      end
    end
  end
end
