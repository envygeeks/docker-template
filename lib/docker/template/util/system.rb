# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Util
      module System
        module_function

        #

        def docker_bin?(bin)
          !bin ? false : File.basename(bin.to_s) == "docker"
        end

        #

        def docker_bin
          bins.find do |path|
            path.basename.fnmatch?("docker") && path.executable_real?
          end&.to_s
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
