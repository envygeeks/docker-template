module Docker
  module Template
    class CLI
      class Build
        def initialize(args, options)
          @options = options
          @repos = Parser.new(args, options).parse
          @args = args
        end

        # --------------------------------------------------------------------

        def start
          _profile do
            @repos.tap { |o| o.map(&:build) }.uniq(&:name).map(
              &:clean
            )
          end
        end

        # --------------------------------------------------------------------

        private
        def _profile
          if !@options.profile?
            yield

          else
            require "memory_profiler"
            profiler = MemoryProfiler.report(:top => 10_240) { yield }
            profiler.pretty_print({
              :to_file => "profile.txt"
            })
          end

        rescue LoadError
          $stderr.puts "The gem 'memory_profiler' wasn't found."
          $stderr.puts "You can install it with `gem install memory_profiler'"
          abort "Hope you install it so you can report back."
        end
      end
    end
  end
end
