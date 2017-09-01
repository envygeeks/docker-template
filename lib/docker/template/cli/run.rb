# Frozen-string-literal: true
# Copyright: 2015 - 2017 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class CLI
      class Run
        def initialize(args, opts)
          @opts = Meta.new(opts || {})
          @repos = Parser.new(args, opts || {}).parse
          @args = args
        end

        # --

        def start
          _profile do
            @repos.tap do |o|
              o.map do |r|
                r.template
                $stdout.puts(
                  r.tmpdir
                )
              end
            end
          end
        end

        # --
        # rubocop:enable Metrics/AbcSize
        # --

        private
        def _profile
          return yield unless @opts.profile?
          Template._require "memory_profiler" do
            profiler = MemoryProfiler.report(:top => 10_240) { yield }
            profiler.pretty_print({
              :to_file => "profile.txt"
            })
          end
        end
      end
    end
  end
end
