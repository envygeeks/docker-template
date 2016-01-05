module Docker
  module Template
    module Loggers
      class Simple
        def log(type, str)
          type == :stderr ? $stderr.print(str) : $stdout.print(str)
        end
      end
    end
  end
end
