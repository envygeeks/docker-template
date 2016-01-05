# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class Normal < Builder

      def unlink(img: false)
        @img.delete "force" => true if @img && img
        @context.rmtree if @context&.directory?
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
        data = Utils::Data.new(:metadata => @repo.metadata)
        data = ERB.new(dockerfile).result(data._binding)
        context = @context.join("Dockerfile")
        context.write(data)
      end

      #

      private
      def cache_context
        if @repo.syncable?
          Utils.create_dockerhub_context self, @context
        end
      end
    end
  end
end
