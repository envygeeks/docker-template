# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "thor"

module Docker
  module Template
    class Interface < Thor
      desc "build <REPOS>", "Build all (or some) of your repostories"
      option "only-sync", :type => :boolean, :desc => "Only sync your repositiries, don't build."
      option "only-push", :type => :boolean, :desc => "Only push your repositories, don't build."
      option :profile,    :type => :boolean, :desc => "Profile Memory."
      option :tty,        :type => :boolean, :desc => "Enable TTY Output."
      option :push,       :type => :boolean, :desc => "Push Repo After Building."
      option :sync,       :type => :boolean, :desc => "Sync your repositories to cache."
      option :mocking,    :type => :boolean, :desc => "Disable Certain Actions."
      option :clean,      :type => :boolean, :desc => "Cleanup images after."

      def build(*args)
        repos = nil; with_profiling do
          repos = Parser.new(args, options).parse
          repos.map &:build
        end
      ensure
        if repos
          Set.new(repos.map { |repo| repo.builder.class }).map do |repo|
            repo.cleanup if repo.respond_to?(
              :cleanup
            )
          end
        end
      end

      # ----------------------------------------------------------------------

      no_tasks do
        def with_profiling
          if options.profile?
            require "memory_profiler"
            MemoryProfiler.report(:top => 10_240) { yield }.pretty_print({\
              :to_file => "mem.txt"
            })

          else
            yield
          end
        rescue LoadError
          abort "Gem 'memory_profiler' not found."

        rescue Exception
          raise unless $ERROR_POSITION
          $ERROR_POSITION.delete_if do |source|
            source =~ %r!#{Regexp.escape(
              __FILE__
            )}!o
          end

          raise
        end
      end
    end
  end
end
