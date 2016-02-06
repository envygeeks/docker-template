# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    class Parser
      SLASH_REGEXP = /\//
      SPLIT_REGEXP = /:|\//
      COLON_REGEXP = /:/

      # ----------------------------------------------------------------------

      def initialize(raw_repos = [], argv = {})
        @raw_repos = raw_repos
        @argv = argv
      end

      # ----------------------------------------------------------------------
      # Return raw_repos if you send us a list of repos you wish to build,
      # otherwise we get the children of the repo folder and ship that off
      # so you can build *every* repo, I don't know if you want that.
      # ----------------------------------------------------------------------

      def all
        return @raw_repos unless @raw_repos.empty?
        return Repo.new.name.to_a if Template.repo_is_root?
        Template.repos_root.children.map do |path|
          path.basename.to_s
        end
      rescue Errno::ENOENT
        then raise Error::RepoNotFound
      end

      # ----------------------------------------------------------------------
      # Parse the given (via ARGV) repositories.
      # ----------------------------------------------------------------------

      def parse
        out = Set.new
        all.each do |val|
          hash = to_repo_hash(val)
          raise Docker::Template::Error::BadRepoName, val if hash.empty?
          out |= Repo.new(hash, @argv).to_repos
        end
        out
      end

      # ----------------------------------------------------------------------
      # Parses: "name", "user/name", "name:tag", "user/name:tag"
      # ----------------------------------------------------------------------

      private
      def to_repo_hash(val)
        data = val.split(SPLIT_REGEXP)

        return "name" => data[0] if data.one?
        return "name" => data[0], "tag"  => data[1] if val =~ COLON_REGEXP && data.size == 2
        return "user" => data[0], "name" => data[1] if val =~ SLASH_REGEXP && data.size == 2
        return "user" => data[0], "name" => data[1], "tag" => data[2] if data.size == 3

        {}
      end
    end
  end
end
