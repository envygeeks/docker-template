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
      :normal => {
        :simple => [
          [:mkdir, "copy"],
          [:write, "copy/usr/local/bin/hello", "world"],
          [:touch, "Dockerfile"],
          [:with_opts, {}]
        ],

        :complex => [
          [:mkdir, "../../copy"],
          [:mkdir, "copy"],
          [:mkdir, "copy/all"],
          [:mkdir, "copy/tag/latest"],
          [:mkdir, "copy/type/normal"],
          [:write, "copy/all/usr/local/bin/hello", "world"],
          [:touch, "Dockerfile"],
          [:with_opts, {}]
        ]
      },

      :scratch => {
        :simple => [
          [:mkdir, "copy"],
          [:write, "copy/usr/local/bin/hello", "world"],
          [:write, "copy/usr/local/bin/mkimg", "hello"],
          [:with_opts, {}]
        ],

        :complex => [
          [:mkdir, "../../copy"],
          [:mkdir, "copy"],
          [:mkdir, "copy/all"],
          [:mkdir, "copy/tag/latest"],
          [:mkdir, "copy/type/normal"],
          [:write, "copy/all/usr/local/bin/hello", "world"],
          [:write, "copy/rootfs/usr/local/bin/mkimg", "hello"],
          [:with_opts, {}]
        ]
      }
    }

    # ------------------------------------------------------------------------

    FS_LAYOUTS[:rootfs] = FS_LAYOUTS[:scratch]
    FS_LAYOUTS.freeze

    # ------------------------------------------------------------------------

    attr_reader :hashes
    attr_reader :original_pwd
    attr_reader :context
    attr_reader :root

    # ------------------------------------------------------------------------
    # @param context the context you are in.  Ship `:cucumber` if in Cucumber.
    # ------------------------------------------------------------------------

    def initialize(context)
      @original_pwd = Dir.pwd
      @root = Pathutil.new(Dir.mktmpdir)
      @context = context

      @hashes = {
        :cli  => {},
        :init => {
          "name" => "default"
        }
      }

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
      return with_opts("tags" => {
        name => group
      })
    end

    # ------------------------------------------------------------------------
    # Adds an alias on your behalf, properly.
    # ------------------------------------------------------------------------

    def add_alias(name, tag: :default)
      return with_opts("aliases" => {
        name => tag
      })
    end

    # ------------------------------------------------------------------------
    # @example mocked_repo.valid_layout?(:scratch, :simple) # => true
    # Determines if a type and layout are valid to use, AKA within the list.
    # @param type the root key in `FS_LAYOUTS`
    # @param layout the subkey in `FS_LAYOUTS`
    # ------------------------------------------------------------------------

    def valid_layout?(type, layout)
      return FS_LAYOUTS.key?(type) && FS_LAYOUTS[type].key?(layout)
    end

    # ------------------------------------------------------------------------
    # Initialize and write all of the files for a given layout, making it
    # possible to run `to_repo` and get back a valid repository to test.
    # @param type the type of layout you wish to use.
    # @param layout the layout you are using.
    #
    # @example
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

    def init(type: :normal, layout: :complex)
      if !valid_layout?(type, layout)
        raise ArgumentError, "Unknown type (#{type}) or " \
          "layout (#{layout})"

      else
        @simple = true if layout == :simple
        FS_LAYOUTS[type][layout].each do |(method, *args)|
          send method, *args
        end

        self
      end
    end

    # ------------------------------------------------------------------------
    # Options being passed to `Repo` as mocked command-line interface args.
    # ------------------------------------------------------------------------

    def with_cli_opts(args)
      @hashes[:cli].deep_merge!(stringify(
        args
      ))

      self
    end

    # ------------------------------------------------------------------------

    def with_repo_init(hash)
      @hashes[:init].deep_merge!(stringify(
        hash
      ))

      self
    end

    # ------------------------------------------------------------------------
    # Write the hash data (`opts`) into the repos `opts.yml` file to mock.
    # @example mocked_repo.with_opts(:hello => :world)
    # ------------------------------------------------------------------------

    def with_opts(opts)
      @hashes[:opts] ||= Docker::Template.config.read_config_from(repo_dir)
      @hashes[:opts] = @hashes[:opts].deep_merge(stringify(opts))
      repo_dir.join("opts.yml").write(
        @hashes[:opts].to_yaml
      )

      self
    end

    # ------------------------------------------------------------------------
    # Pull a Docker image from the system and return the object representation.
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
    # Initialize a repository to run mocks and tests against it.
    # ------------------------------------------------------------------------

    def to_repo
      repo_dir

      Docker::Template::Repo.new(
        @hashes[:init].dup, @hashes[:cli].dup
      )
    end

    # ------------------------------------------------------------------------
    # Initialize a scratch image to run mocks and tests against it.
    # ------------------------------------------------------------------------

    def to_scratch
      Docker::Template::Scratch.new(
        to_repo
      )
    end

    # ------------------------------------------------------------------------
    # Initialize a normal image to run mocks and tests against it.
    # ------------------------------------------------------------------------

    def to_normal
      Docker::Template::Normal.new(
        to_repo
      )
    end

    # ------------------------------------------------------------------------
    # Initialize a rootfs wrapper to run mocks and tests against it.
    # ------------------------------------------------------------------------

    def to_rootfs
      Docker::Template::Rootfs.new(
        to_repo
      )
    end

    # ------------------------------------------------------------------------
    # Empty out the repo root directory, leaving nothing in it's wake.
    # ------------------------------------------------------------------------

    def empty
      @emptied = true
      @root.glob("*").map(
        &:rm_rf
      )

      self
    end

    # ------------------------------------------------------------------------
    # @example mocked_repo.mkdir("hello")
    # @param dir the name of the directory you wish to create.
    # Make an empty directory.
    # ------------------------------------------------------------------------

    def mkdir(dir)
      repo_dir.join(dir).mkdir_p
      self
    end

    # ------------------------------------------------------------------------
    # @example mocked_report.write("hello", "world")
    # @param data the data that will be push into the file you created.
    # @param file the name of the file you wish to create
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
    # @example mocked_repo.touch("my_file")
    # @param file the name of the file you wish to create.
    # Create an empty file of your choosing.
    # ------------------------------------------------------------------------

    def touch(file)
      repo_dir.join(file).touch
      self
    end

    # ------------------------------------------------------------------------
    # Symlink a file within the current repository directory.
    # @example mocked_repo.symlink("/etc", "etc")
    # ------------------------------------------------------------------------

    def symlink(target, name)
      repo_dir.join(target).symlink(repo_dir.join(
        name
      ))

      self
    end

    # ------------------------------------------------------------------------
    # Delete a file from the current repository directory.
    # @param file the name of the file you wish to delete out of the root.
    # @example mocked_repo.delete("hello")
    # ------------------------------------------------------------------------

    def delete(file)
      repo_dir.join(file).rm_r
      self
    end

    # ------------------------------------------------------------------------
    # Link to a file outside of any known and recognized root.
    # @example mocked_repo.symlink("/etc", "etc")
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

    private
    def stringify(hash)
      Docker::Template::Utils::Stringify.hash(
        hash
      )
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
      rtn = @root if simple?
      rtn = @root.join(Docker::Template.config["repos_dir"]).join(@hashes[:init]["name"]) if complex?
      rtn.mkdir_p unless rtn.exist? || emptied?
      rtn
    end

    # ------------------------------------------------------------------------

    alias clear empty
    rb_delegate :emptied?, :to => :@emptied, :type => :ivar, :bool => true
    rb_delegate :complex?, :to => :@simple,  :type => :ivar, :bool => :reverse
    rb_delegate :simple?,  :to => :@simple,  :type => :ivar, :bool => true
    rb_delegate :join,     :to => :@root
  end
end
