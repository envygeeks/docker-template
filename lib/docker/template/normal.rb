# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    class Normal < Builder
      def teardown(img: false)
        @img.delete "force" => true if @img && img
        @context.rmtree if @context && \
            @context.directory?
      end

      # ----------------------------------------------------------------------
      # Copy all the necessary files into the current context.
      # ----------------------------------------------------------------------

      def setup_context
        @context = @repo.tmpdir
        @copy = @context.join("copy")
        copy_dockerfile
        @copy.mkdir
      end

      # ----------------------------------------------------------------------
      # Copy the Dockerfile, first parsing it with ERB with the given data.
      # ----------------------------------------------------------------------

      private
      def copy_dockerfile
        dockerfile = @repo.root.join("Dockerfile").read
        data = Utils::Data.new(:metadata => @repo.metadata)
        data = ERB.new(dockerfile).result(data._binding)
        context = @context.join("Dockerfile")
        context.write(data)
      end

      # ----------------------------------------------------------------------
      # Save the context into the `cache/` folder you designate.
      # ----------------------------------------------------------------------

      private
      def cache_context
        if @repo.syncable?
          Utils::Context.cache self, @context
        end
      end
    end
  end
end
