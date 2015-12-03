module Docker
  module Template
    module Auth
      module_function

      def auth!
        return unless login = credentials
        login["auths"].each do |server, auth|
          username, password = Base64.decode64(auth["auth"]).split(":", 2)
          Docker.authenticate!({
            "username" => username,
            "serveraddress" => server,
            "email" => auth["email"],
            "password" => password
          })
        end
      end

      def credentials
        path = Pathname.new("~/.docker/config.json").expand_path
        JSON.parse(path.read) if path.exist?
      end
    end
  end
end
