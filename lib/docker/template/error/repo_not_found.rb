# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Error
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
