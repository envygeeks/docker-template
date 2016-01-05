# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Utils
      module_function

      #

      autoload :Copy, "docker/template/utils/copy"
      autoload :Stringify, "docker/template/utils/stringify"
      autoload :System, "docker/template/utils/system"
      autoload :Data, "docker/template/utils/data"

      #

      def notify_alias(aliased)
        repo = aliased.repo
        parent_repo = aliased.parent_repo
        $stdout.puts Simple::Ansi.green("Aliasing #{repo} -> #{parent_repo}")
      end

      #

      def notify_build(repo, rootfs: false)
        img = repo.to_s(rootfs: rootfs)
        $stdout.puts Simple::Ansi.green("Building: #{img}")
      end

      #

      def create_dockerhub_context(builder, context)
        dir = builder.repo.cache_dir
        dir.rmtree if dir.exist?

        FileUtils.mkdir_p dir
        $stdout.puts Simple::Ansi.yellow("Copying context for #{builder.repo}")
        Utils::Copy.file(readme_file(builder), dir)
        Utils::Copy.directory(context, dir)
      end

      #

      def readme_file(builder)
        builder.repo.root.children.find do |val|
          val.to_s =~ /readme/i
        end
      end
    end
  end
end
