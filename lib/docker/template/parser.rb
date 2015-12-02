# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class Parser
      SlashRegexp = /\//.freeze
      SplitRegexp = /:|\//.freeze
      ColonRegexp = /:/.freeze

      def initialize(argv = [].freeze)
        @argv = argv.freeze
      end

      # Return ARGV if you send us a list of repos you wish to build,
      # otherwise we get the children of the repo folder and ship that off
      # so you can build *every* repo, I don't know if you want that.

      def all
        return @argv unless @argv.empty?
        Docker::Template.repos_root.children.map do |path|
          path.basename.to_s
        end
      rescue Errno::ENOENT
        raise Error::RepoNotFound
      end

      #

      def parse(as: :repos, out: Set.new)
        all.each do |val|
          hash = build_repo_hash(val)
          raise Docker::Template::Error::BadRepoName, val if hash.empty?
          out += as == :repos ? Repo.new(hash).to_repos : [hash]
        end
      out
      end

      #

      private
      def build_repo_hash(val)
        data, hsh = val.split(SplitRegexp), {}
        if data.size == 1
          hsh["repo"] = data[0]

        elsif val =~ ColonRegexp && data.size == 2
          hsh["repo"] = data[0]
          hsh[ "tag"] = data[1]

        elsif val =~ SlashRegexp && data.size == 2
          hsh["user"] = data[0]
          hsh["repo"] = data[1]

        elsif data.size == 3
          hsh["user"] = data[0]
          hsh["repo"] = data[1]
          hsh[ "tag"] = data[2]
        end

        hsh
      end
    end
  end
end
