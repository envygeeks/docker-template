# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Notify
      module_function

      # --
      # Notify the user of a push that is happening.
      # --

      def push(builder)
        $stderr.puts Simple::Ansi.green(
          "Pushing: #{builder.repo}"
        )
      end

      # --
      # Notify the user that we are tag aliasing.
      # --

      def alias(builder)
        repo = builder.repo
        aliased_repo = builder.aliased_repo || builder.aliased_tag
        msg = Simple::Ansi.green("Aliasing #{repo} -> #{aliased_repo}")
        $stderr.puts msg
      end

      # --

      def build(repo, rootfs: false)
        build_start(repo, {
          :rootfs => rootfs
        })

        if block_given?
          yield
          build_end(repo, {
            :rootfs => rootfs
          })
        end
      end

      # --
      # Notify the user that we are building their repository.
      # --

      def build_start(repo, rootfs: false)
        if ENV["TRAVIS"] && !ENV.key?("RSPEC_RUNNING")
          STDOUT.puts(format("travis_fold:end:%s",
            repo.to_s(:rootfs => rootfs).tr("^A-Za-z0-9", "-").gsub(
              /\-$/, ""
            )
          ))
        end

        $stderr.puts Simple::Ansi.green(format(
          "Building: %s", repo.to_s({
            :rootfs => rootfs
          })
        ))
      end

      # --
      # Notify the user that building their repository has ended.
      # --

      def build_end(repo, rootfs: false)
        if ENV["TRAVIS"] && !ENV.key?("RSPEC_RUNNING")
          STDOUT.puts(format("travis_fold:end:%s",
            repo.to_s(:rootfs => rootfs).tr("^A-Za-z0-9", "-").gsub(
              /\-$/, ""
            )
          ))
        end

        $stderr.puts Simple::Ansi.green(format(
          "Done Building: %s", repo.to_s({
            :rootfs => rootfs
          })
        ))
      end
    end
  end
end
