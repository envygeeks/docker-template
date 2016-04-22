module Docker
  module Template
    module Auth
      module_function

      # ----------------------------------------------------------------------

      DEFAULT_SERVER = "https://index.docker.io/v1/"

      # ----------------------------------------------------------------------
      # Check to see if authing via the environment, that way we can alter.
      # ----------------------------------------------------------------------

      def env?
        ENV.key?("DOCKER_USERNAME") && \
        ENV.key?("DOCKER_PASSWORD") && \
        ENV.key?("DOCKER_EMAIL")
      end

      # ----------------------------------------------------------------------

      def hub
        if env?
          then _hub_env else _hub_config
        end

      rescue Docker::Error::AuthenticationError
        abort(Simple::Ansi.red(
          "Unable to authenticate."
        ))
      end

      # ----------------------------------------------------------------------

      def _hub_env
        Docker.authenticate!({
          "username" => ENV["DOCKER_USERNAME"],
          "serveraddress" => ENV["DOCKER_SERVER"] || DEFAULT_SERVER,
          "password" => ENV["DOCKER_PASSWORD"],
          "email" => ENV["DOCKER_EMAIL"]
        })
      end

      # ----------------------------------------------------------------------

      def _hub_config
        credentials = Pathutil.new("~/.docker/config.json")
        credentials = credentials.expand_path.read_json

        unless credentials.empty?
          credentials["auths"].each do |server_, info|
            username, password = Base64.decode64(info["auth"]).split(
              ":", 2
            )

            Docker.authenticate!({
              "username" => username,
              "serveraddress" => server_,
              "email" => info["email"],
              "password" => password
            })
          end
        end
      end
    end
  end
end
