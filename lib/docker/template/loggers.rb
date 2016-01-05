module Docker
  module Template
    module Loggers
      autoload :API, "docker/template/loggers/api"
      autoload :Simple, "docker/template/loggers/simple"
      autoload :TTY, "docker/template/loggers/tty"
    end
  end
end
