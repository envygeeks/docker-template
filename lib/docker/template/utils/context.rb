module Docker
  module Template
    module Utils
      module Context
        module_function

        #

        def cache(builder, context)
          dir = builder.repo.cache_dir
          dir.rmtree if dir.exist?

          FileUtils.mkdir_p dir
          $stdout.puts Simple::Ansi.yellow("Copying context for #{builder.repo}")
          Utils::Copy.file(readme(builder), dir)
          Utils::Copy.directory(context, dir)
        end

        #

        def readme(builder)
          builder.repo.root.children.find do |val|
            val.to_s =~ /readme/i
          end
        end
      end
    end
  end
end
