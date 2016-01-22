# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Utils
      module Context
        module_function

        # --------------------------------------------------------------------
        # Cache the context into the cache directory for backups or otherwise.
        # @param [Pathutil,Pathname] context the context currently built.
        # @param [Pathutil,Pathname] builder the builder.
        # --------------------------------------------------------------------

        def cache(builder, context)
          return unless context

          builder.repo.cache_dir.rm_rf
          $stdout.puts Simple::Ansi.yellow("Copying context for #{builder.repo}")
          context.cp_r(builder.repo.cache_dir)
          readme(builder)
        end

        # --------------------------------------------------------------------
        # Search for the README file and copy it over to the cache if exists.
        # --------------------------------------------------------------------

        def readme(builder)
          file = builder.repo.root.children.find do |val|
            val =~ /readme/i
          end

          return unless file
          file.safe_copy(builder.repo.cache_dir, {
            :root => file.parent
          })
        end
      end
    end
  end
end
