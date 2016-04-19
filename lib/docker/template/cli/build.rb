module Docker
  module Template
    class CLI
      class Build
        def initialize(args, opts)
          @opts = Metadata.new(opts || {})
          @repos = Parser.new(args, opts || {}).parse
          @args = args
        end

        # --------------------------------------------------------------------

        def start
          _profile do
            reselect_repos if @opts.diff?
            @repos.tap { |o| o.map(&:build) }.uniq(&:name).map(
              &:clean
            )
          end
        end

        # --------------------------------------------------------------------

        def reselect_repos
          Template._require "rugged" do
            git = Rugged::Repository.new(".")
            repos_dir = Template.root.join(@opts.repos_dir)
            walker = Rugged::Walker.new(git)
            walker.push(git.last_commit)

            repos = git.last_commit.parents.each_with_object(Set.new) do |parent, set|
              git.last_commit.diff(parent).each_delta do |delta, file = delta.new_file[:path]|
                if Pathutil.new(file).expand_path(Template.root).in_path?(repos_dir)
                  set.merge(file.split("/").values_at(
                    1
                  ))
                end
              end
            end

            @repos = @repos.select do |repo|
              repos.include?(
                repo.name
              )
            end
          end
        end

        # --------------------------------------------------------------------

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
