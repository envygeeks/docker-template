module Docker
  module Template
    class Interface
      class Opts
        def initialize(opt_p, opt_h, parser)
          @opt_p = opt_p
          @parser = parser
          @opt_h = opt_h

          self.class.instance_methods(false).each do |method|
            send method
          end
        end

        #

        def mocking
          @opt_p.on("--mocking", "--testing", "Disable remote push.") do
            @opt_h.update("mocking" => true, "testing" => true)
          end
        end

        #

        def travis
          @opt_p.on("--travis", "Load a Travis-CI Shell") do
            @opt_h["travis"] = true
          end
        end

        #

        def pry
          @opt_p.on("--pry", "Load a Pry REPL.") do
            @opt_h["pry"] = true
          end
        end

        #

        def tty
          @opt_p.on("--tty", "Enable TTY output.") do
            @opt_h["tty"] = true
          end
        end

        #

        def help
          @opt_p.on("-h", "--help", "Show this message") do
            $stdout.puts @opt_p
            exit 0
          end
        end

        #

        def clean
          @opt_p.on("-c", "--[no-]clean", "Clean the cache folder.") do |bool|
            @opt_h["clean"] = bool
          end
        end

        #

        def push
          @opt_p.on("-p", "--[no-]push", "Push your repos after building.") do |bool|
            @opt_h["push"] = bool
          end
        end

        #

        def sync
          @opt_p.on("-s", "--[no-]sync", "Sync repos to the cache.") do |bool|
            @opt_h["sync"] = bool
          end
        end

        #

        def only_sync
          @opt_p.on("-o", "--sync-only", "Only sync repos, do not build.") do |bool|
            @opt_h["only_sync"] = bool
          end
        end
      end
    end
  end
end
