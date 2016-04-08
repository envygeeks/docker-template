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
        Template.root.join(Metadata.new({}).repos_dir).children.map do |path|
          path.basename.to_s
        end

      rescue Errno::ENOENT
        then raise Error::RepoNotFound
      end

      # ----------------------------------------------------------------------

      def parse
        repos = Set.new
        all.each do |v|
          hash = to_repo_hash(v)
          raise Docker::Template::Error::BadRepoName, v if hash.empty?
          repos |= Repo.new(hash, @argv).to_repos
        end

        repos
      end

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
