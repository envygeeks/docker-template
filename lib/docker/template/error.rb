# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Error
      StandardError = Class.new(
        StandardError
      )

      # ----------------------------------------------------------------------

      class PlaceHolderError < StandardError
        def initialize(error)
          super "PLACEHOLDER ERROR: %s" % (
            error
          )
        end
      end

      # ----------------------------------------------------------------------

      class BadExitStatus < StandardError
        attr_reader :status

        def initialize(status)
          super "Got bad exit status #{
            @status = status
          }"
        end
      end

      # ----------------------------------------------------------------------

      class BadRepoName < StandardError
        def initialize(name)
          super "Only a-z0-9_- are allowed. Invalid repo name: #{
            name
          }"
        end
      end

      # ----------------------------------------------------------------------

      class InvalidRepoType < StandardError
        def initialize(type)
          build_types = Template.config.build_types.join(", ")
          super "Uknown repo type given '#{type}' not in '#{
            build_types
          }'"
        end
      end

      # ----------------------------------------------------------------------

      class InvalidTargzFile < StandardError
        def initialize(tar_gz)
          super "No data was given to the tar.gz file '#{
            tar_gz.basename
          }'"
        end
      end

      # ----------------------------------------------------------------------

      class InvalidYAMLFile < StandardError
        def initialize(file)
          super "The yaml data provided by #{file} is invalid and not a hash."
        end
      end

      # ----------------------------------------------------------------------

      class NoHookExists < StandardError
        def initialize(base, point)
          super "Unknown hook base '#{base}' or hook point '#{
            point
          }'"
        end
      end

      # ----------------------------------------------------------------------

      class NoRootMetadata < StandardError
        def initialize
          super "Metadata without the root flag must provide the root_metadata."
        end
      end

      # ----------------------------------------------------------------------

      class NoRootfsMkimg < StandardError
        def initialize
          super "Unable to find rootfs.rb in your repo folder."
        end
      end

      # ----------------------------------------------------------------------

      class NoSetupContext < StandardError
        def initialize
          super "No #setup_context method exists."
        end
      end

      # ----------------------------------------------------------------------

      class NotImplemented < StandardError
        def initialize
          super "The feature is not implemented yet, sorry about that."
        end
      end

      # ----------------------------------------------------------------------

      class RepoNotFound < StandardError
        def initialize(repo = nil)
          ending = repo ? "the repo '#{repo}'" : "your repo folder"
          super "Unable to find #{
            ending
          }"
        end
      end
    end
  end
end
