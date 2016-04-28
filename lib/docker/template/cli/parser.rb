# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    class CLI
      class Parser
        SLASH_REGEXP = /\//
        SPLIT_REGEXP = /:|\//
        COLON_REGEXP = /:/

        def initialize(raw_repos = [], argv = {})
          @raw_repos = raw_repos
          @argv = argv
        end

        # ----------------------------------------------------------------------
        # Return `raw_repos` if you send us a list of repos you wish to build,
        # otherwise we get the children of the repo folder and ship that off so
        # you can build *every* repo, I don't know if you want that.
        # ----------------------------------------------------------------------

        def all
          return @raw_repos unless @raw_repos.empty?
          return [Template.root.basename.to_s] if Template.project?
          Template.root.join(Metadata.new({}).repos_dir).children.map do |path|
            path.basename.to_s
          end

        rescue Errno::ENOENT
          then raise(
            Error::RepoNotFound
          )
        end

        # ----------------------------------------------------------------------
        # rubocop:disable Metrics/AbcSize
        # ----------------------------------------------------------------------

        def parse
          repos = {
            :scratch => [],
            :simple  => [],
            :aliases => []
          }

          all.each do |v|
            hash = self.class.to_repo_hash(
              v
            )

            if hash.empty?
              raise(Docker::Template::Error::BadRepoName,
                v
              )

            else
              Repo.new(hash, @argv).to_repos.each do |r|
                r.alias?? repos[:aliases] << r : \
                  if r.builder.scratch?
                    then repos[:scratch] << r
                    else repos[ :simple] << r
                  end
              end
            end
          end

          repos.values.reduce(
            :|
          )
        end

        # ----------------------------------------------------------------------
        # rubocop:enable Metrics/AbcSize
        # ----------------------------------------------------------------------

        def self.to_repo_hash(val)
          data = val.to_s.split(SPLIT_REGEXP)

          return "name" => data[0] if data.one?
          return "name" => data[0], "tag"  => data[1] if val =~ COLON_REGEXP && data.size == 2
          return "user" => data[0], "name" => data[1] if val =~ SLASH_REGEXP && data.size == 2
          return "user" => data[0], "name" => data[1], "tag" => data[2] if data.size == 3

          {}
        end

        # ----------------------------------------------------------------------

        def self.full_name?(val)
          parsed = to_repo_hash(val)
          parsed.key?("name") && (parsed.key?("user") || parsed.key?(
            "tag"
          ))
        end
      end
    end
  end
end
