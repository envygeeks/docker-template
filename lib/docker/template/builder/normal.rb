# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class Builder
      class Normal < Builder
        projects_allowed!

        def teardown(img: false)
          @img.delete "force" => true if @img && img
          @context.rmtree if @context && \
            @context.directory?
        end

        # --

        def setup_context
          @context = @repo.tmpdir
          @copy = @context.join("copy")
          copy_dockerfile
          @copy.mkdir
        end

        # --

        private
        def copy_dockerfile
          dockerfile = Template.project?? Template.root : @repo.root
          dockerfile = dockerfile.join("Dockerfile").read

          data = ERB::Context.new(:meta => @repo.meta)
          data = ERB.new(dockerfile).result(data._binding)
          context = @context.join("Dockerfile")
          context.write(data)
        end

        # --

        private
        def cache_context
          return unless @repo.cacheable?
          return Cache.aliased_context(self) if alias?
          Cache.context(self, @context)
        end

        class << self
          def files
            %w(
              Dockerfile
            )
          end
        end
      end
    end
  end
end
