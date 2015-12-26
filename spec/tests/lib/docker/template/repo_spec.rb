# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Repo do
  include_context :repos

  #

  subject do
    mocked_repos.to_repo
  end

  #

  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :tag  }
  it { is_expected.to respond_to :type }
  it { is_expected.to respond_to :user }
  it { is_expected.to respond_to :to_h }

  #

  describe "#initialize" do
    context "when given an invalid type" do
      before do
        mocked_repos.with_opts({
          "type" => "invalid"
        })
      end

      #

      it "should throw" do
        expect { mocked_repos.to_repo }.to raise_error \
          Docker::Template::Error::InvalidRepoType
      end
    end

    #

    context "when repo does not exist" do
      before do
        dir = Docker::Template.config["repos_dir"]
        mocked_repos.empty.disable_repo_dir.mkdir(dir, {
          root: true
        })
      end

      #

      it "should throw" do
        expect { mocked_repos.to_repo }.to raise_error \
          Docker::Template::Error::RepoNotFound
      end
    end

    #

    context "when not a hash" do
      it "should throw" do
        expect { described_class.new("hello") }.to raise_error ArgumentError
      end
    end
  end

  #

  describe "#to_s" do
    context "when no type or type = :image" do
      context "without a user" do
        before do
          mocked_repos.with_opts({
            "user" => "hello"
          })
        end

        #

        it "should use the default user" do
          expect(mocked_repos.to_repo.to_s).to match %r!\Ahello/[a-z]+:[a-z]+\Z!
        end
      end

      #

      context "without a tag" do
        before do
          mocked_repos.with_opts({
            "tag" => "hello"
          })
        end

        #

        it "should use the default tag" do
          expect(mocked_repos.to_repo.to_s).to match %r!\A[a-z]+/[a-z]+:hello!
        end
      end
    end

    context "when type == :rootfs" do
      it "should use the repo name as the tag" do
        prefix = Docker::Template.config["local_prefix"]
        expect(mocked_repos.to_repo.to_s(:rootfs)).to eq "#{prefix}/rootfs:default"
      end
    end
  end

  #

  describe "#copy_dir" do
    it "should be a pathname" do
      expect(mocked_repos.to_repo.copy_dir).to be_a Pathname
    end

    #

    context "(*)" do
      it "should join arguments sent" do
        expect(mocked_repos.to_repo.copy_dir("world").basename.to_s).to eq "world"
      end
    end
  end

  #

  describe "#building_all?" do
    shared_examples_for :building_all do
      context "when no tag is provided" do
        before do
          mocked_repos.with_init({
            "type" => type
          })
        end

        #

        it "should be true" do
          expect(mocked_repos.to_repo.building_all?).to eq true
        end
      end

      #

      context "when a tag is provided" do
        before do
          mocked_repos.with_opts("type" => type).with_init({
            "tag" => "default"
          })
        end

        #

        it "should be false" do
          expect(mocked_repos.to_repo.building_all?).to eq false
        end
      end
    end

    #

    context "when simple" do
      it_should_behave_like :building_all
      let :type do
        "simple"
      end
    end

    #

    context "when scratch" do
      it_should_behave_like :building_all
      let :type do
        "scratch"
      end
    end
  end

  #

  describe "#root" do
    it "should put me into pry" do
      expect(mocked_repos.to_repo.root.relative_path_from(Docker::Template.root). \
        to_s).to eq "repos/default"
    end
  end

  #

  describe "#to_tag_h" do
    it "should include user/repo" do
      expect(mocked_repos.to_repo.to_tag_h).to include({
        "repo" => match(%r!\A[a-z]+/default!)
      })
    end

    #

    it "should include a tag" do
      expect(mocked_repos.to_repo.to_tag_h).to include({
        "tag" => "latest"
      })
    end
  end

  #

  describe "#to_rootfs_h" do
    before do
      mocked_repos.as(:scratch)
    end

    #

    it "should include prefix/rootfs" do
      prefix = Docker::Template.config["local_prefix"]
      expect(mocked_repos.to_repo.to_rootfs_h).to include({
        "repo" => match(%r!\A#{Regexp.escape(prefix)}/rootfs!)
      })
    end

    #

    it "should include a tag" do
      expect(mocked_repos.to_repo.to_rootfs_h).to include({
        "tag" => "default"
      })
    end
  end

  #

  describe "#tmpdir" do
    it "should be a pathname" do
      expect(mocked_repos.to_repo.tmpdir.tap(&:unlink)).to be_a Pathname
    end

    #

    it "should exist" do
      dir = mocked_repos.to_repo.tmpdir
      expect(dir).to exist
      dir.unlink
    end

    #

    context "(*prefixes)" do
      it "should add those prefixes" do
        expect(mocked_repos.to_repo.tmpdir("hello").tap(&:unlink).to_s).to \
          match %r!-hello-!
      end
    end
  end

  #

  describe "#tmpfile" do
    it "should be a Pathname" do
      expect(mocked_repos.to_repo.tmpfile.tap(&:unlink)).to be_a Pathname
    end

    #

    it "should exist" do
      file = mocked_repos.to_repo.tmpfile
      expect(file).to exist
      file.unlink
    end

    #

    context "(*prefixes)" do
      it "should add those prefixes" do
        expect(mocked_repos.to_repo.tmpfile("hello").tap(&:unlink).to_s).to \
          match %r!-hello-!
      end
    end
  end

  #

  describe "#to_repos" do
    context do
      before do
        mocked_repos.with_opts({
          "tags" => {
            "hello" => "world",
            "world" => "hello"
          }
        })
      end

      #

      it "should pull all tags as individual repos" do
        expect(mocked_repos.to_repo.to_repos.size).to eq 2
      end
    end

    #

    context do
      before do
        mocked_repos.with_init({
          "tag" => "default"
        })
      end

      #

      it "should return all repos" do
        expect(mocked_repos.to_repo.to_repos.first).to \
          be_a Docker::Template::Repo
      end
    end

    #

    context "when a tag is given" do
      before do
        mocked_repos.with_init("tag" => "default")
      end

      #

      it "should only return the current repo" do
        expect(mocked_repos.to_repo.to_repos.size).to eq 1
      end
    end
  end

  #

  describe "#metadata" do
    it "should be a Metadata" do
      expect(mocked_repos.to_repo.metadata).to \
        be_a Docker::Template::Metadata
    end
  end

  #

  describe "#to_env_hash" do
    it "should return a hash to you" do
      expect(mocked_repos.to_repo.to_env_hash).to be_a Hash
    end

    #

    context "(tar_gz: val)" do
      it "should include the tar_gz" do
        expect(mocked_repos.to_repo.to_env_hash(tar_gz: "val")).to \
        include({
          "TAR_GZ" => "val"
        })
      end
    end

    #

    context "copy_dir: val" do
      it "should include the copy_dir" do
        expect(mocked_repos.to_repo.to_env_hash(copy_dir: "val")).to \
        include({
          "COPY" => "val"
        })
      end
    end
  end
end
