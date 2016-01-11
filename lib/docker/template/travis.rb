module Docker
  module Template
    module Travis
      NAME = "travis-docker-template"
      module_function

      #

      def create
        system "docker", "run", "--volume=#{Dir.pwd}:/home/travis/builds/envygeeks/docker-template", \
          "--volume=#{Dir.pwd}/vendor/bundle:/home/travis/builds/envygeeks/docker-template/vendor/bundle", \
          "--workdir=/home/travis/builds/envygeeks/docker-template", "--user=travis", "--name=#{NAME}", \
          "-dit", "quay.io/travisci/travis-ruby", "bash"
        system "docker", "exec", "-it", NAME, \
          "bash", "-il"
      end

      #

      def delete
        system "docker", "stop", "-t", "0", NAME
        system "docker", "rm", "-fv", NAME
      end
    end
  end
end
