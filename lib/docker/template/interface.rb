# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "docker/template/parser"
require "optparse"

module Docker
  module Template
    class Interface
      include Hooks::Methods
      register_hook_point :parse
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
          run_hooks :parse, optp
          banner = Util::System.docker_bin?(@zero) ? "docker template" : "docker-template"
          parser.on("-p", "--[no-]push", "Push your repos after building.") { |bool| @argv["push"] = bool }
          parser.on("-s", "--[no-]sync", "Sync repos to the cache.") { |bool| @argv["dockerhub_cache"] = bool }
          parser.on("-c", "--[no-]clean", "Clean the cache folder.") { |bool| @argv["clean"] = bool }
          parser.on("-h", "--help", "Show this message") { $stdout.puts parser; exit 0 }
          parser.banner = "Usage: #{banner} [repos] [flags]"
        end

        @raw_repos = Set.new
        @raw_repos.merge(parser.parse!(@raw_argv.dup))
        @raw_repos.freeze
        @argv.freeze
      end

      #

      def self.start(zero)
        if !Util::System.docker_bin?(zero)
          argv = ARGV[0] == "template" ? ARGV[1..-1] : ARGV
          new(zero, argv).run
        else
          exe = Util::System.docker_bin
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
