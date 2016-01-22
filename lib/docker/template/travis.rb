# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Travis
      NAME = "travis-docker-template"
      module_function

      # ----------------------------------------------------------------------
      # Boot up a Travis-CI Image with our source so that you can debug
      # possible issues you are having with specs failing and you don't know
      # why.  This is rarely useful, but it's useful none-the-less.
      # ----------------------------------------------------------------------

      def create
        system "docker", "run", "--volume=#{Dir.pwd}:/home/travis/builds/envygeeks/docker-template", \
          "--volume=#{Dir.pwd}/vendor/bundle:/home/travis/builds/envygeeks/docker-template/vendor/bundle", \
          "--workdir=/home/travis/builds/envygeeks/docker-template", "--user=travis", "--name=#{NAME}", \
          "-dit", "quay.io/travisci/travis-ruby", "bash"
        system "docker", "exec", "-it", NAME, \
          "bash", "-il"
      end

      # ----------------------------------------------------------------------
      # Stop the Travis-CI Docker image forcefully, and instantly.
      # ----------------------------------------------------------------------

      def stop
        system(
          "docker", "stop", "-t", "0", NAME
        )

        self
      end

      # ----------------------------------------------------------------------
      # Delete the instance of our Docker image once we've stopped it.
      # ----------------------------------------------------------------------

      def delete
        system(
          "docker", "rm", "-fv", NAME
        )

        self
      end
    end
  end
end
