# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Error
      StandardError = Class.new(
        StandardError
      )

      # --

      class UnsuccessfulAuth < StandardError
        def initialize
          super "Unable to authorize you to Dockerhub, something is wrong."
        end
      end

      # --

      class BadExitStatus < StandardError
        attr_reader :status

        def initialize(status)
          super "Got bad exit status #{
            @status = status
          }"
        end
      end

      # --

      class BadRepoName < StandardError
        def initialize(name)
          super "Only a-z0-9_- are allowed. Invalid repo name: #{
            name
          }"
        end
      end

      # --

      class InvalidTargzFile < StandardError
        def initialize(tar_gz)
          super "No data was given to the tar.gz file '#{
            tar_gz.basename
          }'"
        end
      end

      # --

      class InvalidYAMLFile < StandardError
        def initialize(file)
          super "The yaml data provided by #{file} is invalid and not a hash."
        end
      end

      # --

      class NoSetupContext < StandardError
        def initialize
          super "No #setup_context method exists."
        end
      end

      # --

      class NotImplemented < StandardError
        def initialize
          super "The feature is not implemented yet, sorry about that."
        end
      end

      # --

      class RepoNotFound < StandardError
        def initialize(repo = nil)
          ending = repo ? "the repo '#{repo}'" : "your repo folder"
          super "Unable to find #{
            ending
          }"
        end
      end

      # --

      class ImageNotFound < StandardError
        def initialize(image)
          super "Unable to find the image #{
            image
          }"
        end
      end
    end
  end
end
