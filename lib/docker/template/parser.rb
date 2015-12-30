# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class Parser
      SLASH_REGEXP = /\//.freeze
      SPLIT_REGEXP = /:|\//.freeze
      COLON_REGEXP = /:/.freeze

      def initialize(raw_repos = [], argv = {})
        @argv = argv
        @raw_repos = \
          raw_repos
      end

      # Return raw_repos if you send us a list of repos you wish to build,
      # otherwise we get the children of the repo folder and ship that off
      # so you can build *every* repo, I don't know if you want that.

      def all
        return @raw_repos unless @raw_repos.empty?
        return Repo.new.name.to_a if Template.repo_is_root?
        Template.repos_root.children.map do |path|
          path.basename.to_s
        end
      rescue Errno::ENOENT
        then raise Error::RepoNotFound
      end

      #

      def parse
        out = Set.new
        all.each do |val|
          hash = build_repo_hash(val)
          raise Docker::Template::Error::BadRepoName, val if hash.empty?
          out |= Repo.new(hash, @argv).to_repos
        end
        out
      end

      #

      private
      def build_repo_hash(val)
        data = val.split(SPLIT_REGEXP)
        hsh  = {}

        # repo
        if data.one?
          hsh["name"] = data[0]

        # repo:tag
        elsif val =~ COLON_REGEXP && data.size == 2
          hsh["name"] = data[0]
          hsh[ "tag"] = data[1]

        # user/repo
        elsif val =~ SLASH_REGEXP && data.size == 2
          hsh["user"] = data[0]
          hsh["name"] = data[1]

        # user/repo:tag
        elsif data.size == 3
          hsh["user"] = data[0]
          hsh["name"] = data[1]
          hsh[ "tag"] = data[2]
        end
        hsh
      end
    end
  end
end
