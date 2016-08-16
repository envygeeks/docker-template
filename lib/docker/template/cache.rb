# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Cache
      module_function

      # --
      # Cache the context into the cache directory.
      # --

      def context(builder, context)
        builder.repo.cache_dir.rm_rf
        $stderr.puts Simple::Ansi.yellow(format("Copying context for %s", builder.repo))
        cache_dir = builder.repo.cache_dir
        cache_dir.parent.mkdir_p

        context.cp_r(cache_dir.tap(
          &:rm_rf
        ))

        readme(builder)
      end

      # --
      # rubocop:disable Metrics/LineLength
      # --

      def aliased_context(builder)
        if builder.aliased_repo.cache_dir.exist?
          $stderr.puts Simple::Ansi.yellow(format("Copying %s context to %s", builder.aliased_repo, builder.repo))
          builder.aliased_repo.cache_dir.cp_r(builder.repo.cache_dir.tap(
            &:rm_rf
          ))
        end
      end

      # --
      # Cleanup the context caches, removing the caches we no longer need.
      # rubocop:enable Metrics/LineLength
      # --

      def cleanup(repo)
        return unless repo.clean_cache?
        cache_dir = repo.cache_dir.parent

        if cache_dir.exist?
          cache_dir.children.each do |file|
            next unless repo.meta.tags.include?(file.basename)
            $stdout.puts Simple::Ansi.yellow(format("Removing %s.",
              file.relative_path_from(Template.root)
            ))

            file.rm_rf
          end
        end
      end

      # --
      # Note: We normally expect but do not require you to have a README.
      # Search for and copy the readme if available.
      # --

      def readme(builder)
        return unless file = builder.repo.root.children.find { |val| val =~ /readme/i }
        file.safe_copy(builder.repo.cache_dir, {
          :root => file.parent
        })
      end
    end
  end
end
