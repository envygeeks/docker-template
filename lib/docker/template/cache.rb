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
        return unless context

        builder.repo.cache_dir.rm_rf
        $stderr.puts Simple::Ansi.yellow("Copying context for #{builder.repo}")
        cache_dir = builder.repo.cache_dir
        cache_dir.parent.mkdir_p

        readme(builder)
        context.cp_r(cache_dir.tap(
          &:rm_rf
        ))
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
