module Docker
  module Template
    module Loggers
      class TTY
        def log(stream)
          $stdout.print stream
        end
      end
    end
  end
end
