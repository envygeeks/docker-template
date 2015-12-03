# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    class Interface
      def initialize(argv = [])
        @argv = argv
      end

      #

      def self.push?
        ARGV.include?("--push")
      end

      #

      def run
        unless only_sync?
          Parser.new(argv_without_flags).parse.map do |repo|
            repo.disable_sync! if wants_sync?
            repo.build
          end
        end

        sync
      end

      #

      private
      def sync
        return unless wants_sync?
        Parser.new.parse.each do |repo|
          next unless repo.syncable?
          repo.builder.tap(&:sync) \
            .unlink(sync: false)
        end
      end

      #

      private
      def argv_without_flags
        @argv.select do |val|
          !["--sync", "--push"].include?(val)
        end
      end

      #

      private
      def only_sync?
        @argv == [
          "--sync"
        ]
      end

      #

      private
      def wants_sync?
        @argv.include?("--sync")
      end

      # Determine whether we are the Docker bin so that we can transform
      # based on that... for example we will pass on commands to `docker` if
      # we are running as the `docker` binary in place of `docker`.

      private
      def self.bin?(bin)
        !bin ? false : File.basename(bin.to_s) == "docker"
      end

      # Discover the Docker bin using Ruby.  This is a highly unoptimized
      # method and needs to be reworked because it's pretty trashy shit and
      # it's just flat out ugly to look at, make it better than it is.

      private
      def self.discover
        rtn = bins.find do |path|
          path.basename.fnmatch?("docker") && path.executable_real?
        end

        if rtn
          rtn.to_s
        end
      end

      #

      private
      def self.start(zero)
        return new(ARGV[1..-1]).run if ARGV[0] == "template" && bin?(zero)
        return new(ARGV).run unless bin?(zero)

        exe = discover
        exec exe.to_s, *ARGV if exe
        abort "No Docker."
      rescue Error::StandardError => error_
        $stderr.puts Ansi.red(error_.message)
        $stderr.puts Ansi.red("Aborting your build. Bye and good luck.")
        exit error_.respond_to?(:status) ? error_.status.to_i : 1
      end

      #

      private
      def self.bins
        ENV["PATH"].split(":").each_with_object(Set.new) do |val, array|
          array.merge(Pathname.new(val).children) rescue next
        end
      end
    end
  end
end
