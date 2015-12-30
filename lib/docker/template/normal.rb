# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    Hooks.register_name :normal, :context_cache

    class Normal < Common
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
          Hooks.load_internal(:normal, :context_cache) \
            .run(:normal, :context_cache, self)
        end
      end
    end
  end
end
