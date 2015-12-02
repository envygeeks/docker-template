# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Util module_function
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
        tags = builder.repo.root.join("tags")
        readme = builder.repo.root.children.select { |val| val.to_s =~ /readme/i }.first
        context = tags.join(builder.repo.aliased) if builder.aliased?
        dir = tags.join(builder.repo.tag)

        FileUtils.mkdir_p dir
        $stdout.puts Ansi.yellow("Storing a Docker context for #{builder.repo}")
        Util::Copy.directory(context, dir)
        Util::Copy.file(readme, dir)
      end
    end
  end
end
