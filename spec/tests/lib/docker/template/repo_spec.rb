# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "rspec/helper"
describe Docker::Template::Repo do
  include_context :repos

  #

  subject do
    mocked_repo.to_repo
  end

  #

  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :tag  }
  it { is_expected.to respond_to :type }
  it { is_expected.to respond_to :user }
  it { is_expected.to respond_to :to_h }

  #

  describe "#initialize" do
    context "when repo does not exist" do
      it "should throw" do
        expect { mocked_repo.empty.to_repo }.to raise_error(
          Docker::Template::Error::RepoNotFound
        )
      end
    end
  end

  #

  describe "#aliased" do
    before do
      mocked_repo.add_alias :world, :tag => :hello
      mocked_repo.add_tag :hello, :group => :world
      mocked_repo.with_repo_init({
        :tag => :world
      })
    end

    it "should pull out the aliased repo" do
      expect(mocked_repo.to_repo.aliased.tag).to eq(
        "hello"
      )
    end
  end

  #

  describe "#to_s" do
    context "when no type or type = :image" do
      context "without a user" do
        before do
          mocked_repo.with_opts({
            "user" => "hello"
          })
        end

        #

        it "should use the default user" do
          expect(mocked_repo.to_repo.to_s).to match(
            %r!\Ahello/[a-z]+:[a-z]+\Z!
          )
        end
      end

      #

      context "without a tag" do
        before do
          mocked_repo.with_opts({
            "tag" => "hello"
          })
        end

        #

        it "should use the default tag" do
          expect(mocked_repo.to_repo.to_s).to match(
            %r!\A[a-z]+/[a-z]+:hello!
          )
        end
      end
    end

    context "when rootfs: true" do
      it "should use the repo name as the tag" do
        prefix = Docker::Template::Metadata::DEFAULTS["local_prefix"]
        expect(mocked_repo.to_repo.to_s(rootfs: true)).to eq(
          "#{prefix}/rootfs:default"
        )
      end
    end
  end

  #

  describe "#copy_dir" do
    it "should be a pathname" do
      expect(mocked_repo.to_repo.copy_dir).to be_a(
        Pathutil
      )
    end

    #

    context "(*)" do
      it "should join arguments sent" do
        expect(mocked_repo.to_repo.copy_dir("world").basename.to_s).to eq(
          "world"
        )
      end
    end
  end

  #

  describe "#root" do
    it "should put me into pry" do
      expect(mocked_repo.to_repo.root.relative_path_from(Docker::Template.root).to_s).to eq(
        "repos/default"
      )
    end
  end

  #

  describe "#to_tag_h" do
    it "should include user/repo" do
      expect(mocked_repo.to_repo.to_tag_h).to \
        include({
          "repo" => match(%r!\A[a-z]+/default!)
        })
    end

    #

    it "should include a tag" do
      expect(mocked_repo.to_repo.to_tag_h).to \
        include({
          "tag" => "latest"
        })
    end
  end

  #

  describe "#to_rootfs_h" do
    before do
      mocked_repo.init({
        :type => :scratch
      })
    end

    #

    it "should include prefix/rootfs" do
      prefix = Docker::Template::Metadata::DEFAULTS["local_prefix"]
      expect(mocked_repo.to_repo.to_rootfs_h).to include({
        "repo" => match(%r!\A#{Regexp.escape(prefix)}/rootfs!)
      })
    end

    #

    it "should include a tag" do
      expect(mocked_repo.to_repo.to_rootfs_h).to \
        include({
          "tag" => "default"
        })
    end
  end

  #

  describe "#tmpdir" do
    it "should be a pathname" do
      expect(mocked_repo.to_repo.tmpdir.tap(&:rm_rf)).to be_a(
        Pathutil
      )
    end

    #

    it "should exist" do
      dir = mocked_repo.to_repo.tmpdir
      expect(dir).to exist
      dir.rm_rf
    end

    #

    context "(*prefixes)" do
      it "should add those prefixes" do
        expect(mocked_repo.to_repo.tmpdir("hello").tap(&:rm_rf).to_s).to match(
          %r!-hello-!
        )
      end
    end
  end

  #

  describe "#tmpfile" do
    it "should be a Pathutil" do
      expect(mocked_repo.to_repo.tmpfile.tap(&:rm_rf)).to be_a(
        Pathutil
      )
    end

    #

    it "should exist" do
      file = mocked_repo.to_repo.tmpfile
      expect(file).to exist
      file.rm_rf
    end

    #

    context "(*prefixes)" do
      it "should add those prefixes" do
        expect(mocked_repo.to_repo.tmpfile("hello").tap(&:rm_rf).to_s).to match(
          %r!-hello-!
        )
      end
    end
  end

  #

  describe "#to_repos" do
    context do
      before do
        mocked_repo.with_opts({
          "tags" => {
            "hello" => "world",
            "world" => "hello"
          }
        })
      end

      #

      it "should pull all tags as individual repos" do
        expect(mocked_repo.to_repo.to_repos.size).to eq(
          2
        )
      end
    end

    #

    context do
      before do
        mocked_repo.with_repo_init({
          "tag" => "default"
        })
      end

      #

      it "should return all repos" do
        expect(mocked_repo.to_repo.to_repos.first).to be_a(
          Docker::Template::Repo
        )
      end
    end

    #

    context "when a tag is given" do
      before do
        mocked_repo.with_repo_init({
          "tag" => "default"
        })
      end

      #

      it "should only return the current repo" do
        expect(mocked_repo.to_repo.to_repos.size).to eq(
          1
        )
      end
    end
  end

  #

  describe "#metadata" do
    it "should be a Metadata" do
      expect(mocked_repo.to_repo.metadata).to be_a(
        Docker::Template::Metadata
      )
    end
  end

  #

  describe "#to_env" do
    it "should return a hash to you" do
      expect(mocked_repo.to_repo.to_env).to be_a(
        Docker::Template::Metadata
      )
    end

    #

    context "(tar_gz: val)" do
      let :result do
        mocked_repo.to_repo.to_env({
          :tar_gz => "val"
        })
      end

      it "should include the tar_gz" do
        expect(result[:all]).to include({
          "TAR_GZ" => "val"
        })
      end
    end

    #

    context "copy_dir: val" do
      let :result do
        mocked_repo.to_repo.to_env({
          :copy_dir => "val"
        })
      end

      it "should include the copy_dir" do
        expect(result[:all]).to include({
          "COPY_DIR" => "val"
        })
      end
    end
  end
end
