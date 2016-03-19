# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Notify
      module_function

      # ----------------------------------------------------------------------
      # Notify the user of a push that is happening.
      # ----------------------------------------------------------------------

      def push(builder)
        $stderr.puts Simple::Ansi.green(
          "Pushing: #{builder.repo}"
        )
      end

      # ----------------------------------------------------------------------
      # Notify the user that we are tag aliasing.
      # ----------------------------------------------------------------------

      def alias(builder)
        repo = builder.repo
        aliased_repo = builder.aliased_repo
        msg = Simple::Ansi.green("Aliasing #{repo} -> #{aliased_repo}")
        $stderr.puts msg
      end

      # ----------------------------------------------------------------------
      # Notify the user that we are building their repository.
      # ----------------------------------------------------------------------

      def build(repo, **kwd)
        img = repo.to_s(**kwd)
        msg = Simple::Ansi.green("Building: #{img}")
        $stderr.puts msg
      end
    end
  end
end
