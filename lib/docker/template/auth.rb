# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Auth
      module_function

      # --

      DEFAULT_SERVER = "https://index.docker.io/v1/"

      # --

      def auth_with_env?
        (
          ENV.key?("DOCKER_USERNAME") && \
          ENV.key?("DOCKER_PASSWORD") && \
          ENV.key?("DOCKER_EMAIL")
        ) || \
        (
          ENV.key?("bamboo_dockerUsername") && \
          ENV.key?("bamboo_dockerPassword") && \
          ENV.key?("bambo_dockerEmail")
        )
      end

      # --

      def hub
        return auth_from_env if auth_with_env?

        auth_from_config
      rescue Docker::Error::AuthenticationError
        raise Error::UnsuccessfulAuth
      end

      # --

      def auth_from_env
        Docker.authenticate!({
          "username" => ENV["DOCKER_USERNAME"] || ENV["bamboo_dockerUsername"],
          "serveraddress" => ENV["DOCKER_SERVER"] || ENV["bamboo_dockerServer"] || DEFAULT_SERVER,
          "password" => ENV["DOCKER_PASSWORD"] || ENV["bamboo_dockerPassword"],
          "email" => ENV["DOCKER_EMAIL"] || ENV["bamboo_dockerEmail"]
        })
      end

      # --

      def auth_from_config
        credentials = Pathutil.new("~/.docker/config.json")
        credentials = credentials.expand_path.read_json

        unless credentials.empty?
          credentials["auths"].each do |server, info|
            username, password = Base64.decode64(info["auth"])
              .split(":", 2)

            Docker.authenticate!({
              "username" => username,
              "serveraddress" => server,
              "email" => info["email"],
              "password" => password
            })
          end
        end
      end
    end
  end
end
