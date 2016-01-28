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
      # rubocop:disable Lint/RescueException
      # ----------------------------------------------------------------------

      def with_profiling
        if profile?
          require "memory_profiler"
          MemoryProfiler.report(:top => 10_240) { yield }.pretty_print({\
            :to_file => "mem.txt"
          })

        else
          yield
        end
      rescue LoadError
        abort "You must install 'memory_profiler' " \
          "to use memory profiling."

      rescue Exception => _error
        $ERROR_POSITION.delete_if do |source|
          source =~ %r!#{Regexp.escape(
            __FILE__
          )}!o
        end

        raise
      end

      # ----------------------------------------------------------------------
      # rubocop:enable Lint/RescueException
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
