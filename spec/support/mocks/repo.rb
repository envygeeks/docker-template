# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "yaml"

module Mocks
  class Repo
    extend Forwardable::Extended

    FS_LAYOUTS = {
      :normal => [
        [:mkdir, "../../copy"],
        [:mkdir, "copy"],
        [:mkdir, "copy/all"],
        [:mkdir, "copy/tag/latest"],
        [:mkdir, "copy/group/normal"],
        [:write, "copy/all/usr/local/bin/hello", "world"],
        [:touch, "Dockerfile"],
        [:with_opts, {}]
      ],

      :scratch => [
        [:mkdir, "../../copy"],
        [:mkdir, "copy"],
        [:mkdir, "copy/all"],
        [:mkdir, "copy/tag/latest"],
        [:mkdir, "copy/group/normal"],
        [:write, "copy/all/usr/local/bin/hello", "world"],
        [:write, "rootfs.erb", "hello"],
        [:mkdir, "copy/rootfs/"],
        [:with_opts, {}]
      ]
    }

    # ------------------------------------------------------------------------

    FS_LAYOUTS[:rootfs] = FS_LAYOUTS[
      :scratch
    ]

    # ------------------------------------------------------------------------

    FS_LAYOUTS.freeze
    attr_reader :hashes
    attr_reader :original_pwd
    attr_reader :context
    attr_reader :root

    # ------------------------------------------------------------------------

    def initialize(context)
      @original_pwd = Dir.pwd
      @root = Pathutil.new(Dir.mktmpdir)
      @context = context

      @hashes = HashWithIndifferentAccess.new({
        :cli  => {},
        :init => {
          :name => "default"
        }
      })

    rescue
      if @root && @root.exist?
        then @root.rm_rf
      end

      raise
    end

    # ------------------------------------------------------------------------
    # Adds a tag to opts.yml properly, on your behalf.
    # ------------------------------------------------------------------------

    def add_tag(name, group: :normal)
      return with_opts(:tags => {
        name => group
      })
    end

    # ------------------------------------------------------------------------
    # Adds an alias on your behalf, properly.
    # ------------------------------------------------------------------------

    def add_alias(name, tag: :default)
      return with_opts(:aliases => {
        name => tag
      })
    end

    # ------------------------------------------------------------------------
    # Determines if a type and layout are valid to use, AKA within the list.
    # Example: mocked_repo.valid_layout?(:scratch, :simple) #=> true
    # ------------------------------------------------------------------------

    def valid_layout?(type)
      return FS_LAYOUTS.key?(
        type
      )
    end

    # ------------------------------------------------------------------------
    # Initialize and write all of the files for a given layout, making it
    # possible to run `to_repo` and get back a valid repository to test.
    # type - the type of layout you wish to use.
    # lyout - the layout you are using.
    #
    # Example:
    #   mocked_repo.init({
    #     :type   => :normal,
    #     :layout => :complex
    #   )
    #
    #   File: /tmp/*/repos/*/copy
    #   File: /tmp/*/repos/*/Dockerfile
    #   File: /tmp/*/repos/*/copy/usr/local/bin/hello
    #   File: /tmp/*/repos/*/opts.yml
    # ------------------------------------------------------------------------

    def init(type: :normal)
      if !valid_layout?(type)
        raise ArgumentError, "Unknown layout type (#{
          type
        })"

      else
        FS_LAYOUTS[type].each do |(m, *a)|
          send m, *a
        end

        self
      end
    end

    # ------------------------------------------------------------------------
    # Options being passed to `Repo`.
    # ------------------------------------------------------------------------

    def with_cli_opts(args)
      @hashes[:cli] = @hashes[:cli].deep_merge(
        args.stringify
      )

      self
    end

    # ------------------------------------------------------------------------

    def with_repo_init(hash)
      @hashes[:init] = @hashes[:init].deep_merge(
        hash.stringify
      )

      self
    end

    # ------------------------------------------------------------------------
    # Example: mocked_repo.with_opts(:hello => :world)
    # Write the hash data into the repos `opts.yml`
    # ------------------------------------------------------------------------

    def with_opts(opts)
      @hashes[:opts] ||= repo_dir.join(Docker::Template::Metadata::OPTS_FILE).read_yaml
      @hashes[:opts] = @hashes[:opts].deep_merge(opts.stringify)
      repo_dir.join("opts.yml").write(
        @hashes[:opts].to_yaml
      )

      self
    end

    # ------------------------------------------------------------------------

    def to_img
      Docker::Image.get(
        to_repo.to_s
      )

    rescue => e
      if e.is_a?(Docker::Error::NotFoundError)
        then nil else raise e
      end
    end

    # ------------------------------------------------------------------------

    def to_repo
      repo_dir
      Docker::Template::Repo.new(
        @hashes[:init].dup, @hashes[:cli].dup
      )
    end

    # ------------------------------------------------------------------------
    # to_rootfs, to_normal, to_scratch
    # ------------------------------------------------------------------------

    %W(Scratch Normal Rootfs).each do |k|
      define_method "to_#{k.downcase}" do
        Docker::Template.const_get(k).new(
          to_repo
        )
      end
    end

    # ------------------------------------------------------------------------

    def empty
      @emptied = true
      @root.glob("*").map(
        &:rm_rf
      )

      self
    end

    # ------------------------------------------------------------------------
    # Example: mocked_repo.mkdir("hello")
    # Make an empty directory!
    # ------------------------------------------------------------------------

    def mkdir(dir)
      repo_dir.join(dir).mkdir_p
      self
    end

    # ------------------------------------------------------------------------
    # Example: mocked_rep.write("hello", "world")
    # Make a file and write data to it.
    # ------------------------------------------------------------------------

    def write(file, data)
      path = repo_dir.join(file)
      path.dirname.mkdir_p
      path.write(
        data
      )

      self
    end

    # ------------------------------------------------------------------------
    # Example: mocked_repo.touch("my_file")
    # Create an empty file of your choosing.
    # ------------------------------------------------------------------------

    def touch(file)
      repo_dir.join(file).touch
      self
    end

    # ------------------------------------------------------------------------
    # Symlink a file within the current repository directory.
    # Example: mocked_repo.symlink("/etc", "etc")
    # ------------------------------------------------------------------------

    def symlink(target, name)
      repo_dir.join(target).symlink(repo_dir.join(
        name
      ))

      self
    end

    # ------------------------------------------------------------------------
    # Delete a file from the current repository directory.
    # Example: mocked_repo.delete("hello")
    # ------------------------------------------------------------------------

    def delete(file)
      repo_dir.join(file).rm_r
      self
    end

    # ------------------------------------------------------------------------
    # Link to a file outside of any known and recognized root.
    # Example: mocked_repo.symlink("/etc", "etc")
    # ------------------------------------------------------------------------

    def external_symlink(target, name)
      Pathutil.new(target).symlink(repo_dir.join(
        name
      ))

      self
    end

    # ------------------------------------------------------------------------

    def setup
      @context.allow(Dir).to @context.receive(:pwd).and_return @root if rspec?
      @context.allow(Docker::Template).to context.receive(:root).and_return @root if rspec?
      Docker::Template.stub(:root).and_return @root unless rspec?
      Dir.stub(:pwd).and_return @repo.to_s unless rspec?
    end

    # ------------------------------------------------------------------------

    def teardown
      @root.rm_rf
    end

    # ------------------------------------------------------------------------

    def rspec?
      @context.is_a?(
        RSpec::Core::ExampleGroup
      )
    end

    # ------------------------------------------------------------------------

    private
    def repo_dir
      rtn = @root.join(Docker::Template::Metadata::DEFAULTS[:repos_dir], @hashes[:init][:name])
      rtn.mkdir_p unless rtn.exist? || emptied?
      rtn
    end

    # ------------------------------------------------------------------------

    alias clear empty
    rb_delegate :emptied?, :to => :@emptied, :type => :ivar, :bool => true
    rb_delegate :join,     :to => :@root
  end
end
