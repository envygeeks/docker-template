# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Cache
      module_function

      # ----------------------------------------------------------------------
      # Cache the context into the cache directory.
      # ----------------------------------------------------------------------

      def context(builder, context)
        if builder.alias? && builder.aliased_repo.cache_dir.exist?
          parent_cache_dir = builder.aliased_repo.cache_dir
          $stderr.puts Simple::Ansi.yellow("Copying #{builder.aliased_repo} context to #{builder.repo}")
          cache_dir = builder.repo.cache_dir

          parent_cache_dir.cp_r(cache_dir.tap(
            &:rm_rf
          ))
        elsif context
          builder.repo.cache_dir.rm_rf
          $stderr.puts Simple::Ansi.yellow("Copying context for #{builder.repo}")
          cache_dir = builder.repo.cache_dir
          cache_dir.parent.mkdir_p

          readme(builder)
          context.cp_r(cache_dir.tap(
            &:rm_rf
          ))
        end
      end

      # ----------------------------------------------------------------------
      # Cleanup the context caches, removing the caches we no longer need.
      # ----------------------------------------------------------------------

      def cleanup(repo)
        cache_dir = repo.cache_dir.parent

        if repo.cacheable? && cache_dir.exist?
          then cache_dir.children.each do |file|
            unless repo.metadata.tags.include?(file.basename)
              $stdout.puts Simple::Ansi.yellow("Removing %s." % [
                file.relative_path_from(Template.root)
              ])

              file.rm_rf
            end
          end
        end
      end

      # ----------------------------------------------------------------------
      # Note: We normally expect but do not require you to have a README.
      # Search for and copy the readme if available.
      # ----------------------------------------------------------------------

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
