# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Utils
      module System
        module_function

        #

        def docker_bin?(bin)
          !bin ? false : File.basename(bin.to_s) == "docker"
        end

        #

        def docker_bin
          rtn = bins.find do |path|
            path.basename.fnmatch?("docker") && path.executable_real?
          end

          if rtn
            then rtn.to_s
          end
        end

        #

        def bins
          ENV["PATH"].split(":").each_with_object(Set.new) do |val, set|
            path = Pathname.new(val)
            if path.directory?
              set.merge path.children
            end
          end
        end
      end
    end
  end
end
