# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "thor"

module Docker
  module Template
    class CLI < Thor

      # ----------------------------------------------------------------------
      # docker-template build [repos [opts]]
      # ----------------------------------------------------------------------

      desc "build [REPOS [OPTS]]", "Build all (or some) of your repostories"
      option :sync_only,  :type => :boolean, :desc => "Only sync your repositiries, don't build."
      option :push_only,  :type => :boolean, :desc => "Only push your repositories, don't build."
      option :profile,    :type => :boolean, :desc => "Profile Memory."
      option :tty,        :type => :boolean, :desc => "Enable TTY Output."
      option :push,       :type => :boolean, :desc => "Push Repo After Building."
      option :sync,       :type => :boolean, :desc => "Sync your repositories to cache."
      option :mocking,    :type => :boolean, :desc => "Disable Certain Actions."
      option :clean,      :type => :boolean, :desc => "Cleanup images after."

      # ----------------------------------------------------------------------

      def build(*args)
        repos = nil

        with_profiling do
          Parser.new(args, options).parse.map(
            &:build
          )
        end
      rescue Docker::Template::Error::StandardError => e
        $stderr.puts Simple::Ansi.red(e.message)
        exit e.respond_to?(:status) ? e.status : 1
      end

      # ----------------------------------------------------------------------
      # docker-template list [options]
      # ----------------------------------------------------------------------

      desc "list [OPTS]", "List all possible builds."
      option :grep, :type => :boolean, :desc => "Make --only a Regexp search."
      option :only, :type => :string,  :desc => "Only a specific repo."

      # ----------------------------------------------------------------------

      def list
        Parser.new([], {}).parse.each do |repo|
          repo_s = repo_s = repo.to_s.gsub(/^[^\/]+\//, "")
          next unless (only.is_a?(Regexp) && repo_s =~ only) \
            || (only && repo_s == only) || !only

          $stderr.print repo.to_s
          $stderr.print " -> ", repo.aliased.to_s, "\n" if repo.alias?
          $stderr.puts unless repo.alias?
        end
      rescue Docker::Template::Error::StandardError => e
        $stderr.puts Simple::Ansi.red(e.message)
        exit e.respond_to?(:status) \
          ? e.status : 1
      end

      # ----------------------------------------------------------------------

      no_tasks do
        def only
          return @only ||= begin
            if !options.grep?
              then options[
                :only
              ]

            elsif options.only?
              Regexp.new(options[
                :only
              ])
            end
          end
        end

        # --------------------------------------------------------------------
        # When a user wishes to profile their builds to see memory being used.
        # rubocop:disable Lint/RescueException
        # --------------------------------------------------------------------

        def with_profiling
          if options.profile?
            begin
              require "memory_profiler"
              MemoryProfiler.report(:top => 10_240) { yield }.pretty_print({\
                :to_file => "mem.txt"
              })
            rescue LoadError
              $stderr.puts "The gem 'memory_profiler' wasn't found."
              $stderr.puts "You can install it with `gem install memory_profiler'"
              abort "Hope you install it so you can report back."
            end

          else
            yield
          end

        rescue Excon::Errors::SocketError
          $stderr.puts "Unable to connect to your Docker Instance."
          $stderr.puts "Are you absolutely sure that you have the Docker installed?"
          abort "Unable to build your images."

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
