module Docker
  module Template
    module Utils
      module Context
        module_function

        #

        def cache(builder, context)
          return unless context

          builder.repo.cache_dir.rm_rf
          $stdout.puts Simple::Ansi.yellow("Copying context for #{builder.repo}")
          context.cp_r(builder.repo.cache_dir)
          readme(builder)
        end

        #

        def readme(builder)
          file = builder.repo.root.children.find do |val|
            val =~ /readme/i
          end

          if file
            then file.safe_copy(
              builder.repo.cache_dir, :root => file.parent
            )
          end
        end
      end
    end
  end
end
