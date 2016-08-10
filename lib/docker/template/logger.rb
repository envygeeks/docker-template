# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class Logger
      def initialize(repo = nil)
        @lines = { 0 => 0 }
        @repo = \
          repo
      end

      # --

      def output?
        return !!@output
      end

      # --

      def increment
        @lines.update({
          @lines.size => @lines.size
        })
      end

      # --
      # A simple TTY stream that just prints out the data that it is given.
      # This is the logger that most will use for most of their building.
      # --

      def tty(stream)
        @output = true
        $stdout.print stream.encode(
          "utf-8"
        )
      end

      # --
      # A simple logger that accepts a multi-type stream.
      # --

      def simple(type, str)
        str ||= ""

        type == :stderr ? $stderr.print(str.encode("utf-8")) : $stdout.print(
          str.encode("utf-8")
        )
      end

      # --
      # A more complex streamer designed for the actual output of the Docker.
      # --
      # This method will save parts into a buffer until it can either parse
      # that buffer or it parses the actual part itself, if it can parse the
      # part itself, it will first dump the buffer as errors and then parse.
      # --
      # This method has to buffer because Docker-API (or Excon, it's depend)
      # gives us no indication of whether or not this is part of a larger chunk
      # it just dumps it on us, so we have to blindly work around that.
      # --

      def api(part, *args)
        part = part.encode("utf-8")
        chunked_part = @chunks.push(part).join if @chunks && !@chunks.empty?
        chunked_part = part if !@chunks
        stream = JSON.parse(
          chunked_part
        )

        if chunked_part == part && @chunks && !@chunks.empty?
          then @chunks.each do |chunk|
            $stderr.puts format("Unparsable JSON: %s",
              chunk
            )
          end
        end

        @chunks = nil
        return progress_bar(stream) if stream.any_key?("progress", "progressDetail")
        return output(stream["status"] || stream["stream"]) if stream.any_key?("status", "stream")
        return progress_error(stream) if stream.any_key?("errorDetail", "error")
        warn Simple::Ansi.red("Unhandled Stream.")
        $stdout.puts(
          part
        )

        @output = true
      rescue JSON::ParserError => e
        (@chunks ||= []).push(
          part
        )
      end

      # --

      def output(msg)
        unless filter_matches?(msg)
          $stdout.puts msg
          increment
        end

        @output = true
      end

      # --

      def progress_error(stream)
        abort Object::Simple::Ansi.red(
          stream["errorDetail"]["message"]
        )
      end

      # --

      private
      def progress_bar(stream)
        id = stream["id"]

        return unless id
        before, diff = progress_diff(id)
        $stderr.print before if before
        str = stream["progress"] || stream["status"]
        str = "#{id}: #{str}\r"

        $stderr.print(Object::Simple::Ansi.jump(
          str, diff
        ))
      end

      # --

      private
      def progress_diff(id)
        if @lines.key?(id)
          return nil, @lines.size - @lines[id]
        end

        @lines[id] = @lines.size
        before = "\n" unless @lines.one?
        return before, 0
      end

      # --

      private
      def filter_matches?(msg)
        return false unless @repo

        @repo.meta["log_filters"].any? do |filter|
          filter.is_a?(Regexp) && msg =~ filter || msg == filter
        end
      end
    end
  end
end
