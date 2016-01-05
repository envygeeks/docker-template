# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Utils
      module Notify
        module_function

        #

        def alias(builder)
          repo = builder.repo
          parent_repo = builder.parent_repo
          msg = Simple::Ansi.green("Aliasing #{repo} -> #{parent_repo}")
          $stdout.puts msg
        end

        #

        def build(repo, **kwd)
          img = repo.to_s(**kwd)
          msg = Simple::Ansi.green("Building: #{img}")
          $stdout.puts msg
        end
      end
    end
  end
end
