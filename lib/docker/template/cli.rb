# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "thor"

module Docker
  module Template
    class CLI < Thor
      autoload :Build, "docker/template/cli/build"
      autoload :List,  "docker/template/cli/list"

      # ----------------------------------------------------------------------
      # docker-template build [repos [opts]]
      # ----------------------------------------------------------------------

      desc "build [REPOS [OPTS]]", "Build all (or some) of your repositories"
      option :diff,       :type => :boolean, :desc => "Build only modified repositories."
      option :cache_only, :type => :boolean, :desc => "Only cache your repositories, don't build."
      option :clean_only, :type => :boolean, :desc => "Only clean your repositories, don't build."
      option :push_only,  :type => :boolean, :desc => "Only push  your repositories, don't build."
      option :profile,    :type => :boolean, :desc => "Profile Memory."
      option :tty,        :type => :boolean, :desc => "Enable TTY Output."
      option :push,       :type => :boolean, :desc => "Push Repo After Building."
      option :cache,      :type => :boolean, :desc => "Cache your repositories to cache."
      option :mocking,    :type => :boolean, :desc => "Disable Certain Actions."
      option :clean,      :type => :boolean, :desc => "Cleanup your caches."
      option :help,       :type => :boolean, :desc => "Output this."

      # ----------------------------------------------------------------------
      # rubocop:disable Lint/RescueException
      # ----------------------------------------------------------------------

      def build(*args)
        return help(__method__) if options.help?
        Build.new(args, options) \
          .start

      rescue Docker::Template::Error::StandardError => e
        $stderr.puts Simple::Ansi.red(e.message)
        exit e.respond_to?(:status) ? \
          e.status : 1

      rescue Exception => _e
        raise unless $ERROR_POSITION
        $ERROR_POSITION.delete_if do |source|
          source =~ %r!#{Regexp.escape(
            __FILE__
          )}!o
        end
      end

      # ----------------------------------------------------------------------
      # rubocop:enable Lint/RescueException
      # docker-template list [options]
      # ----------------------------------------------------------------------

      option :help, :type => :boolean, :desc => "Output this."
      desc "list [OPTS]", "List all possible builds."

      # ----------------------------------------------------------------------

      def list
        return help(__method__) if options.help?
        return $stdout.puts(
          List.build
        )
      end
    end
  end
end
