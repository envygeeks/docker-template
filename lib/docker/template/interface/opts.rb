# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

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

        # --------------------------------------------------------------------
        # Allows you to enable memory profiling, so you can see how bad I am.
        # --------------------------------------------------------------------

        def profile
          @opt_p.on("--profile", "Profile Memory Usage.") do
            @opt_h["profile"] = true
          end
        end

        # --------------------------------------------------------------------
        # Enables testing (or mocking) whatever you call it, so that you don't
        # do certain actions when testing with things like Cucumber.
        # @note --mocking | --testing
        # --------------------------------------------------------------------

        def mocking
          @opt_p.on("--mocking", "--testing", "Disable remote push.") do
            @opt_h.update("mocking" => true, "testing" => true)
          end
        end

        # --------------------------------------------------------------------
        # Loads a Travis-CI shell with the Travis-CI Docker image, this is
        # a pretty hefty image on a pretty slow server so be careful.
        # @note --travis
        # --------------------------------------------------------------------

        def travis
          @opt_p.on("-T", "--travis", "Load a Travis-CI Shell") do
            @opt_h["travis"] = true
          end
        end

        # --------------------------------------------------------------------
        # This is useful for when you want to play around.
        # @note --pry
        # --------------------------------------------------------------------

        def pry
          @opt_p.on("-P", "--pry", "Load a Pry REPL.") do
            @opt_h["pry"] = true
          end
        end

        # --------------------------------------------------------------------
        # Enable TTY output, this only works on scratch.
        # @note --tty
        # --------------------------------------------------------------------

        def tty
          @opt_p.on("-t", "--tty", "Enable TTY output.") do
            @opt_h["tty"] = true
          end
        end

        # --------------------------------------------------------------------

        def help
          @opt_p.on("-h", "--help", "Show this message") do
            $stdout.puts @opt_p
            exit 0
          end
        end

        # --------------------------------------------------------------------
        # Clean out the cache folder and remove all the old.
        # @note --clean
        # --------------------------------------------------------------------

        def clean
          @opt_p.on("-c", "--[no-]clean", "Clean the cache folder.") do |bool|
            @opt_h["clean"] = bool
          end
        end

        # --------------------------------------------------------------------
        # Push your repositories to the Docker hub after build.
        # @note --push
        # --------------------------------------------------------------------

        def push
          @opt_p.on("-p", "--[no-]push", "Push your repos after building.") do |bool|
            @opt_h["push"] = bool
          end
        end

        # --------------------------------------------------------------------
        # Sync your contexts to `cache/` so you can build with Dockerhub.
        # @note --sync
        # --------------------------------------------------------------------

        def sync
          @opt_p.on("-s", "--[no-]sync", "Sync repos to the cache.") do |bool|
            @opt_h["sync"] = bool
          end
        end

        # --------------------------------------------------------------------
        # Do not do anything but build the context & sync.
        # @note --sync-only
        # --------------------------------------------------------------------

        def only_sync
          @opt_p.on("-o", "--sync-only", "Only sync repos, do not build.") do |bool|
            @opt_h["only_sync"] = bool
          end
        end
      end
    end
  end
end
