# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "docker/template/common"

module Docker
  module Template
    class Normal < Common
      register_hook_point :cache_context

      def unlink(img: false)
        @img.delete "force" => true if @img && img
        if @context && @context.directory?
          then @context.rmtree
        end
      end

      #

      def setup_context
        @context = @repo.tmpdir
        @copy = @context.join("copy")
        copy_dockerfile
        @copy.mkdir
      end

      #

      private
      def copy_dockerfile
        dockerfile = @repo.root.join("Dockerfile").read
        data = Util::Data.new(:metadata => @repo.metadata)
        data = ERB.new(dockerfile).result(data._binding)
        context = @context.join("Dockerfile")
        context.write(data)
      end

      private
      def cache_context
        if @repo.syncable?
          Util.create_dockerhub_context self, @context
          run_hooks :cache_context
        end
      end
    end
  end
end
