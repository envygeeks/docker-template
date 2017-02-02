# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "docker/template"
require "thor"

module Docker
  module Template
    class CLI < Thor

      # --

      option :force, :type => :boolean, :desc => "Force caching."
      desc "cache [REPOS [OPTS]]", "Cache all (or some) of your repositories."
      option :clean, :type => :boolean, :desc => "Cleanup your caches."
      option :help, :type => :boolean, :desc => "Output this."

      # --

      def cache(*args)
        return help(__method__) if options.help?
        self.options = options.merge(:cache => true) if options.force?
        self.options = options.merge(:cache_only => true)
        return build(
          *args
        )
      end

      # --

      option :force, :type => :boolean, :desc => "Force cleaning."
      desc "clean [REPOS [OPTS]]", "Clean all (or some) of your repositories caches."
      option :help, :type => :boolean, :desc => "Output this."

      # --

      def clean(*args)
        return help(__method__) if options.help?
        self.options = options.merge(:clean => true) if options.force?
        self.options = options.merge(:clean_only => true)
        return build(
          *args
        )
      end

      # --

      option :force, :type => :boolean, :desc => "Force cleaning."
      desc "push [REPOS [OPTS]]", "Push all (or some) of your repositories."
      option :help, :type => :boolean, :desc => "Output this."

      # --

      def push(*args)
        return help(__method__) if options.help?
        self.options = options.merge(:push => true) if options.force?
        self.options = options.merge(:push_only => true)
        return build(
          *args
        )
      end

      # --
      # docker-template build [repos [opts]]
      # --

      desc "build [REPOS [OPTS]]", "Build all (or some) of your repositories."
      option :profile,    :type => :boolean, :desc => "Profile Memory."
      option :tty,        :type => :boolean, :desc => "Enable TTY Output."
      option :cache,      :type => :boolean, :desc => "Cache your repositories to cache."
      option :exclude,    :type => :array,   :desc => "Build everything except for these images."
      option :debug,      :type => :boolean, :desc => "Send the DEBUG=true env var to your instance."
      option :diff,       :type => :boolean, :desc => "Build only modified repositories."
      option :push,       :type => :boolean, :desc => "Push Repo After Building."
      option :clean,      :type => :boolean, :desc => "Cleanup your caches."
      option :force,      :type => :boolean, :desc => "Force your build."
      option :squash,     :type => :boolean, :desc => "Squash the build."
      option :help,       :type => :boolean, :desc => "Output this."

      # --
      # rubocop:disable Lint/RescueException
      # --

      def build(*args)
        return help(__method__) if options.help?
        Build.new(args, options)
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

      # --
      # rubocop:enable Lint/RescueException
      # docker-template list [options]
      # --

      option :help, :type => :boolean, :desc => "Output this."
      desc "list [OPTS]", "List all possible builds."

      # --

      def list
        return help(__method__) if options.help?
        return $stdout.puts(
          List.build
        )
      end
    end
  end
end

require "docker/template/cli/build"
require "docker/template/cli/list"
