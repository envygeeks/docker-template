# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "optparse"

module Docker
  module Template
    class Interface
      def initialize(zero, argv = [])
        @zero = zero
        @raw_argv = argv
        setup
      end

      #

      def run
        Parser.new(@raw_repos, @argv).parse.map(&:build)
      end

      #

      def setup
        @argv = {}
        parser = OptParse.new do |optp|
          banner = Utils::System.docker_bin?(@zero) ? "docker template" : "docker-template"
          optp.on("-p", "--[no-]push", "Push your repos after building.") { |bool| @argv["push"] = bool }
          optp.on("-s", "--[no-]sync", "Sync repos to the cache.") { |bool| @argv["dockerhub_cache"] = bool }
          optp.on("-c", "--[no-]clean", "Clean the cache folder.") { |bool| @argv["clean"] = bool }
          optp.on("-h", "--help", "Show this message") { $stdout.puts parser; exit 0 }
          optp.on("--tty", "Enable TTY output.") { |bool| @argv["tty"] = true }
          optp.banner = "Usage: #{banner} [repos] [flags]"
        end

        @raw_repos = Set.new
        @raw_repos.merge(parser.parse!(@raw_argv.dup))
        @raw_repos.freeze
        @argv.freeze
      end

      #

      def self.start(zero)
        if !Utils::System.docker_bin?(zero)
          ARGV.unshift if ARGV.first == "template"
          new(zero, ARGV).run
        else
          exe = Utils::System.docker_bin
          return exec exe.to_s, *ARGV if exe
          abort "No Docker."
        end

      rescue Error::StandardError => error
        $stderr.puts Simple::Ansi.red(error.message)
        $stderr.puts Simple::Ansi.red("Aborting your build.")
        exit error.status rescue 1
      end
    end
  end
end
