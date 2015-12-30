# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    Hooks.register_name :normal, :sync

    class Normal < Common

      #

      def sync
        copy_build_and_verify unless @context
        Hooks.load_internal(:normal, :sync).run(:normal, :sync, self)
        Util.create_dockerhub_context(self, @context)
      end

      #

      def unlink(img: false, sync: true)
        self.sync if sync && @repo.syncable?
        @context.rmtree if @context && @context.directory?
        @img.delete "force" => true if @img && img
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
    end
  end
end
