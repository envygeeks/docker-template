# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Util
      module_function

      autoload :Copy, "docker/template/util/copy"
      autoload :Data, "docker/template/util/data"

      def notify_alias(aliased)
        repo = aliased.repo
        parent_repo = aliased.parent_repo
        $stdout.puts Ansi.green("Aliasing #{repo} -> #{parent_repo}")
      end

      #

      def notify_build(repo, rootfs: false)
        img = rootfs ? repo.to_rootfs_s : repo.to_s
        $stdout.puts Ansi.green("Building: #{img}")
      end

      #

      def create_dockerhub_context(builder, context)
        dir = builder.repo.root.join(builder.repo.metadata["dockerhub_cache_dir"], builder.repo.tag)
        context = get_context(builder, context)
        FileUtils.mkdir_p dir

        $stdout.puts Ansi.yellow("Copying context for #{builder.repo}")
        Util::Copy.file(readme_file(builder), dir)
        Util::Copy.directory(context, dir)
      end

      #

      def get_context(builder, context)
        return context unless builder.aliased?
        builder.repo.root.join("tags", builder.repo.aliased)
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
