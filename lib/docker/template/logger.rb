# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    class Logger
      def initialize(builder = nil)
        @lines = { "" => "" }
        @builder = \
          builder
      end

      # ----------------------------------------------------------------------
      # A simple TTY stream that just prints out the data given it.
      # ----------------------------------------------------------------------

      def tty(stream)
        $stdout.print stream
      end

      # ----------------------------------------------------------------------
      # A simple logger that accepts a multi-type stream.
      # ----------------------------------------------------------------------

      def simple(type, str)
        type == :stderr ? $stderr.print(str) : $stdout.print(str)
      end

      # ----------------------------------------------------------------------
      # A more complex streamer designed for the actual output of Docker.
      # @param [String<JSON:Hash>] part the JSON part given.
      # ----------------------------------------------------------------------

      def api(part, *_)
        retried ||= false

        stream = JSON.parse(part)
        return progress_bar(stream) if stream.any_keys?("progress", "progressDetail")
        return output(stream["status"] || stream["stream"]) if stream.any_keys?("status", "stream")
        return progress_error(stream) if stream.any_keys?("errorDetail", "error")

        warn Object::Simple::Ansi.red("Unhandled stream message")
        $stderr.puts Object::Simple::Ansi.red("Please file a bug ticket.")
        $stdout.puts part
      rescue JSON::ParserError => e
        if !retried
          retried = true
          part = "#{part}\" }"
          retry
        else
          raise e
        end
      end

      # ----------------------------------------------------------------------

      def output(msg)
        unless filter_matches?(msg)
          $stdout.print msg
        end
      end

      # ----------------------------------------------------------------------

      def progress_error(stream)
        abort Object::Simple::Ansi.red(
          stream["errorDetail"]["message"]
        )
      end

      # ----------------------------------------------------------------------

      private
      def progress_bar(stream)
        id = stream["id"]

        return unless id
        before, diff = progress_diff(id)
        $stdout.print before if before
        str = stream["progress"] || stream["status"]
        str = "#{id}: #{str}\r"

        $stdout.print(Object::Simple::Ansi.jump(
          str, diff
        ))
      end

      # ----------------------------------------------------------------------

      private
      def progress_diff(id)
        if @lines.key?(id)
          return nil, @lines.size - @lines[id]
        end

        @lines[id] = @lines.size
        before = "\n" unless @lines.one?
        return before, 0
      end

      # ----------------------------------------------------------------------

      private
      def filter_matches?(msg)
        return false unless @builder

        @builder.repo.metadata["log_filters"].any? do |filter|
          filter.is_a?(Regexp) && msg =~ filter || msg == filter
        end
      end
    end
  end
end
