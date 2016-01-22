# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Utils
      module System
        module_function

        # -------------------------------------------------------------------
        # @param [String] bin the value to be checked.
        # Determine if the given value is a "docker" binary so we can alter
        # our CLI behavior for that.
        # ---------------------------------------------------------------------

        def docker_bin?(bin)
          !bin ? false : File.basename(bin.to_s) == "docker"
        end

        # --------------------------------------------------------------------
        # Pull out the binaries on the system and find out which is Docker.
        # --------------------------------------------------------------------

        def docker_bin
          rtn = bins.find do |path|
            path.basename.fnmatch?("docker") && path.executable_real?
          end

          if rtn
            then rtn.to_s
          end
        end

        # --------------------------------------------------------------------
        # Get a list of system bins so that we can we can use them to find.
        # --------------------------------------------------------------------

        def bins
          ENV["PATH"].split(":").each_with_object(Set.new) do |val, set|
            path = Pathutil.new(val)
            if path.directory?
              set.merge path.children
            end
          end
        end
      end
    end
  end
end
