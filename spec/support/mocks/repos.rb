# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "yaml"

module Mocks
  class Repos
    RUNNERS = {
      :normal => [
        [:mkdir, "copy"],
        [:write, "copy/all/usr/local/bin/hello", "world"],
        [:touch, "Dockerfile"],
        [:with_opts, {}]
      ],

      :simple_normal => [
        [:mkdir, "copy"],
        [:write, "copy/usr/local/bin/hello", "world"],
        [:touch, "Dockerfile"],
        [:with_opts, {}]
      ],

      :scratch => [
        [:mkdir, "copy"],
        [:write, "copy/all/usr/local/bin/hello", "world"],
        [:write, "copy/rootfs/usr/local/bin/mkimg", "hello"],
        [:with_opts, {}]
      ],

      :simple_scratch => [
        [:mkdir, "copy"],
        [:write, "copy/usr/local/bin/hello", "world"],
        [:write, "copy/usr/local/bin/mkimg", "hello"],
        [:with_opts, {}]
      ]
    }

    #

    def initialize(context)
      @tmpdir = Dir.mktmpdir
      @dir = Pathname.new(@tmpdir)
      @make_repo_dir = true
      @context = context
      make_readable

      stub
    rescue => error
      @dir.rmtree if @dir && @dir.exist?
      raise error
    end

    #

    def join(*paths)
      strip_and_split(*paths)
    end

    #

    def as(what)
      return clear.as(what) if @already_ran_as
      raise ArgumentError, "Unknown runner #{what}" unless RUNNERS.key?(what)
      @simple = true if what.to_s.start_with?("simple_")
      @already_ran_as = true

      RUNNERS[what].each do |(method, *args)|
        send method, *args
      end

      self
    end

    #

    def disable_repo_dir
      @make_repo_dir = false
      self
    end

    #

    def with_init(args)
      @init ||= {}
      @init.merge!(args.stringify)
      self
    end

    #

    def with_opts(opts)
      @opts ||= {}
      pre_data = Docker::Template.config.read_config_from(strip_and_split)
      @opts = pre_data.merge(@opts).merge(opts.stringify)
      write "opts.yml", @opts.to_yaml
      self
    end

    #

    def to_repo(init = nil)
      repo.as_repo(init || @init)
    end

    #

    [:scratch, :simple, :rootfs].each do |val|
      define_method "to_#{val}" do
        Docker::Template.const_get(val.capitalize).new(to_repo)
      end
    end

    #

    def delete(*paths)
      strip_and_split(*paths).rmtree
      self
    end

    #

    def mkdir(*paths)
      FileUtils.mkdir_p strip_and_split(*paths)
      self
    end

    #

    def symlink(target, name, **kwd)
      target = strip_and_split(target, **kwd)
      name   = strip_and_split(  name, **kwd)
      FileUtils.ln_s(target, name)
      self
    end

    #

    def external_symlink(target, name)
      FileUtils.ln_s(target, strip_and_split(name))
      self
    end

    #

    def touch(*paths)
      file = strip_and_split(*paths)

      mkdir file.dirname
      FileUtils.touch(file)
      self
    end

    #

    def write(*paths, data, **kwd)
      file = strip_and_split(*paths, **kwd)

      mkdir file.dirname
      File.open(file, "w+:utf-8") do |fiol|
        fiol.write data
      end

      self
    end

    #

    def empty
      repo
      @dir.glob("*").map(&:rmtree)
      self
    end

    #

    def clear
      teardown
      new_self = self.class.new(@context)
      @context.__memoized.memoized[:mocked_repos] = new_self
      new_self
    rescue => error
      new_self.teardown if new_self
      raise error
    end

    #

    def teardown
      @dir.rmtree if @dir && @dir.exist?
    end

    #

    private
    def stub
      @context.allow(Dir).to @context.receive(:pwd).and_return @dir
      @context.allow(Docker::Template).to @context.receive(:root).and_return @dir
    end

    #

    private
    def repo
      @repo ||= begin
        repos_dir = Docker::Template.config["repos_dir"]
        tag = @init.is_a?(Hash) && @init["tag"] ? @init["tag"] : "default"
        rtn = patch(@dir.join(repos_dir, tag))

        @simple ? rtn = @dir : (if @make_repo_dir
          FileUtils.mkdir_p(rtn)
        end)

        repos_root = @simple ? rtn : @dir.join(repos_dir)
        # That way no matter which route you go get at it, you can get at it.
        @context.allow(Docker::Template).to @context.receive(:repos_root).and_return repos_root
        rtn
      end
    end

    #

    private
    def strip_and_split(*paths, root: false)
      joined = root ? @dir : repo
      path = File.join(paths.flatten).to_s.gsub(%r!#{Regexp.escape(repo.to_s)}\/?!, "")
      joined.join(*File.split(path))
    end

    #

    private
    def make_readable
      @context.instance_variable_get(:@__memoized).class.send(:attr_reader, :memoized)
      @context.class.send(:attr_reader, \
        :__memoized)
    end

    #

    private
    def patch(val)
      val.instance_eval do
        def as_repo(init = {})
          init ||= {}

          Docker::Template::Repo.new(init.merge({
            "repo" => basename.to_s
          }))
        end
      end

      val
    end
  end
end
