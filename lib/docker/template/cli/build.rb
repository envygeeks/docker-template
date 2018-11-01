# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class CLI
      class Build
        def initialize(args, opts)
          @opts = Meta.new(opts || {})
          @repos = Parser.new(args, opts || {}).parse
          @args = args
        end

        # --

        def start
          _profile do
            changed! if @opts.diff?
            exclude! if @opts.exclude?
            @repos.tap { |o| o.map(&:build) }.uniq(&:name).map(
              &:clean
            )
          end
        end

        # --

        def exclude!
          Parser.new(@opts[:exclude].map { |v| v.split(/,\s*/) }.flatten.compact).parse.each do |repo|
            @repos.delete_if do |v|
              v.name == repo.name && v.tag == repo.tag
            end
          end
        end

        # --
        # rubocop:disable Metrics/AbcSize
        # --

        def changed!
          Template._require "rugged" do |loaded|
            return true unless loaded

            git = Rugged::Repository.new(Template.root.to_s)
            dir = Template.root.join(@opts.repos_dir)

            repos = git.last_commit.diff.each_delta.each_with_object(Set.new) do |delta, set|
              next unless Pathutil.new(delta.new_file[:path]).expand_path(Template.root).in_path?(dir)
              set.merge(delta.new_file[:path].split("/").values_at(
                1
              ))
            end

            @repos = @repos.select do |repo|
              repos.include?(
                repo.name
              )
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
