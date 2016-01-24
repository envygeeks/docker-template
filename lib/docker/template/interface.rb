# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "optparse"

module Docker
  module Template
    class Interface
      extend Forwardable::Extended
      autoload :Opts, "docker/template/interface/opts"
      rb_delegate "travis", :to => :@argv, :bool => true, :type => :hash
      rb_delegate "profile", :to => :@argv, :bool => true, :type => :hash
      rb_delegate "pry", :to => :@argv, :bool => true, :type => :hash

      # ----------------------------------------------------------------------

      def initialize(zero, argv = [])
        @zero = zero
        @raw_argv = argv
        setup
      end

      # ----------------------------------------------------------------------

      def run
        return if travis? || pry?
        with_profiling do
          Parser.new(@raw_repos, @argv).parse.map(
            &:build
          )
        end
      end

      # ----------------------------------------------------------------------

      def with_profiling
        if profile?
          require "memory_profiler"
          profiler = MemoryProfiler.report(:top => 10_240) { yield }
          profiler.pretty_print(:to_file => "mem.txt")
        else
          yield
        end
      rescue LoadError
        abort "You must install 'memory_profiler' " \
          "for profiling to work."
      end

      # ----------------------------------------------------------------------

      def setup
        @argv  = {}
        parser = OptParse.new do |opt_p|
          banner = Utils::System.docker_bin?(@zero) ? "docker template" : "docker-template"
          opt_p.banner = "Usage: #{banner} [repos] [flags]"
          Opts.new(opt_p, @argv, parser)
        end

        @raw_repos = Set.new
        @raw_repos.merge(parser.parse!(@raw_argv.dup))
        @raw_repos.freeze
        @argv.freeze
        travis
        pry
      end

      # ----------------------------------------------------------------------

      def travis
        return unless travis?

        Travis.create
        Travis.delete
        exit 0
      end

      # ----------------------------------------------------------------------

      def pry
        return unless pry?

        require "pry"
        Pry.output = STDOUT
        Pry.config.docker_template_repos = @raw_repos
        Template.gem_root.join("lib/docker/template/cmd/pry").children.each { |file| require file }
        Pry.config.docker_template_argv = @argv
        Template.pry
      end

      # ----------------------------------------------------------------------

      def self.start(zero)
        ARGV.unshift if ARGV.first == "template"
        if !Utils::System.docker_bin?(zero)
          new(zero, ARGV).run
        else
          exe = Utils::System.docker_bin
          return exec exe.to_s, *ARGV if exe
          abort "No System Docker."
        end

      rescue Error::StandardError => error
        $stderr.puts Simple::Ansi.red(error.message)
        $stderr.puts Simple::Ansi.red("Aborting your build.")
        exit error.status rescue 1
      end
    end
  end
end
