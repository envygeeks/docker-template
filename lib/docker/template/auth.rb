# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "open3"
require "json"

module Docker
  module Template
    class Auth
      DEFAULT_SERVER = "https://index.docker.io/v1/"
      def initialize(repo)
        @repo = repo
      end

      def auth_with_cmd?
        @repo.user =~ %r!/!
      end

      def auth_with_env?
        ENV.key?("DOCKER_USERNAME") && \
        ENV.key?("DOCKER_PASSWORD") && \
        ENV.key?("DOCKER_EMAIL")
      end

      # --
      def auth(skip: nil)
        return auth_from_cmd if auth_with_cmd? && skip != :cmd
        return auth_from_env if auth_with_env? && skip != :env
        auth_from_config

      # Wrap around their error to create ours.
      rescue Docker::Error::AuthenticationError
        raise Error::UnsuccessfulAuth
        # Something went wrong?
      end

      # --
      def auth_from_cmd
        case @repo.user
        when %r!^gcr\.io/! then auth_from_gcr
        else
          auth({
            skip: :cmd
          })
        end
      end

      # --
      def auth_from_env
        Docker.authenticate!({
          "username" => ENV["DOCKER_USERNAME"],
          "serveraddress" => ENV["DOCKER_SERVER"] || DEFAULT_SERVER,
          "password" => ENV["DOCKER_PASSWORD"],
          "email" => ENV["DOCKER_EMAIL"]
        })
      end

      # --
      def auth_from_config
        cred = Pathutil.new("~/.docker/config.json")
        cred = cred.expand_path.read_json

        unless cred.empty?
          cred["auths"].each do |server, info|
            next if info.empty?

            user, pass = Base64.decode64(info["auth"]).split(":", 2)
            Docker.authenticate!({
              "username" => user,
              "serveraddress" => server,
              "email" => info["email"],
              "password" => pass
            })
          end
        end
      end

      private
      def auth_from_gcr
        i, o, e, = Open3.popen3("docker-credential-gcr get")
        server, = @repo.user.split("/", 2)

        i.puts server; i.close
        val = JSON.parse(o.read.chomp)
        [o, e].map(&:close)

        if val
          Docker.authenticate!({
            "serveraddress" => server,
            "username" => val["Username"],
            "email" => "docker-template+opensource@envygeeks.io",
            "password" => val["Secret"],
          })
        end
      end
    end
  end
end
