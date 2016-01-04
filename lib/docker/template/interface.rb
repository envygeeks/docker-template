# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

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
        Parser.new(@raw_repos, @argv).parse.map do |repo|
          repo.build
        end
      end

      #

      def setup
        @argv = {}
        parse = OptParse.new do |parser|
          run_hooks :parse, parser
          banner_bin = self.class.bin?(@zero) ? "docker template" : "docker-template"
          parser.banner = "Usage: #{banner_bin} [repos] [flags]"
        end

        @raw_repos = Set.new
        @raw_repos.merge(parse.parse!(@raw_argv.dup))
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
