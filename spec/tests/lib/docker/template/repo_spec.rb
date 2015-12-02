# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Repo do
  subject { repo.new("repo" => "simple") }
  let(:repo) { described_class }

  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :tag  }
  it { is_expected.to respond_to :type }
  it { is_expected.to respond_to :user }
  it { is_expected.to respond_to :to_h }

  describe "#initialize" do
    subject { repo.new("repo" => "simple") }
    it { is_expected.to be_a repo }

    context "when given an invalid type" do
      subject { -> { described_class.new("repo" => "type") }}
      let(:error) {  Docker::Template::Error::InvalidRepoType  }
      specify { expect(&subject).to raise_error error }
    end

    context "when repo does not exist" do
      let(:error) { Docker::Template::Error::RepoNotFound }
      subject { -> { described_class.new("repo" => "uknown") }}
      specify { expect(&subject).to raise_error error }
    end

    context "when not a hash" do
      subject { -> { repo.new("hello") }}
      specify { expect(&subject).to raise_error ArgumentError }
    end
  end

  describe "#to_s" do
    context "without a user" do
      subject { repo.new("tag" => "world", "repo" => "simple").to_s }
      it { is_expected.to match %r!\A[a-z]+/simple:world\Z! }
    end

    context "without a tag" do
      it { is_expected.to match %r!\A[a-z]+/simple:latest\Z! }
      subject { repo.new("repo" => "simple").to_s }
    end
  end

  describe "#copy_dir" do
    subject { repo.new("repo" => "simple").copy_dir }
    it { is_expected.to be_a Pathname }

    context "(*)" do
      specify { expect(subject.basename.to_s).to eq "world" }
      subject { repo.new("repo" => "simple").copy_dir("world") }
      it { is_expected.to be_a Pathname }
    end
  end

  describe "#building_all?" do
    subject { repo.new("repo" => "simple").building_all? }
    it { is_expected.to eq true }

    context "type is scratch w/out tag" do
      subject { repo.new("repo" => "scratch").building_all? }
      it { is_expected.to be true }
    end

    context "type is scratch w/ tag" do
      subject { repo.new("tag" => "simple", "repo" => "scratch").building_all? }
      it { is_expected.to eq false }
    end

    context "type is simple" do
      subject { repo.new("repo" => "simple").building_all? }
      it { is_expected.to eq true }
    end

    context "type is simple w/ tag" do
      subject { repo.new("tag" => "hello", "repo" => "simple").building_all? }
      it { is_expected.to eq false }
    end
  end

  describe "#to_rootfs_s" do
    subject { repo.new("repo" => "simple", "user" => "everyone", "tag" => "world").to_rootfs_s }
    it { is_expected.to match %r!\A[a-z]+/rootfs:simple\Z! }
  end

  describe "#root" do
    subject { repo.new("repo" => "simple").root }
    specify { expect(subject.relative_path_from(Docker::Template.root).to_s).to eq "repos/simple" }
    it { is_expected.to be_a Pathname }
  end

  describe "#to_tag_h" do
    subject { repo.new("repo" => "scratch").to_tag_h }
    it { is_expected.to include "repo" => match(%r!\A[a-z]+/scratch!) }
    it { is_expected.to include "tag" => "latest" }
    it { is_expected.to include "force" => true }
  end

  describe "#to_rootfs_h" do
    subject { repo.new("repo" => "scratch").to_rootfs_h }
    it { is_expected.to include "repo" => match(%r!\A[a-z]+/rootfs!) }
    it { is_expected.to include "tag" => "scratch" }
    it { is_expected.to include "force" => true }
  end

  describe "#tmpdir" do
    after { subject.rmtree rescue nil }
    subject { repo.new("repo" => "scratch").tmpdir }
    it { is_expected.to be_a Pathname }
    it { is_expected.to exist }

    context "(*prefix)" do
      subject { repo.new("repo" => "scratch").tmpdir("hello").tap(&:unlink).to_path }
      it { is_expected.to match %r!\-hello\-! }
    end
  end

  describe "#tmpfile" do
    it { is_expected.to be_a Pathname }
    subject { repo.new("repo" => "scratch").tmpfile }
    after { subject.unlink rescue nil }
    it { is_expected.to exist }

    context "(*prefixes)" do
      subject { repo.new("repo" => "scratch").tmpfile("hello").tap(&:unlink).to_path }
      it { is_expected.to match %r!\-hello\-! }
    end
  end

  describe "#to_repos" do
    subject { repo.new("repo" => "scratch").to_repos }
    specify { expect(subject.size).to be > 1 }

    context "when a tag is given" do
      subject { repo.new("repo" => "scratch", "tag" => "latest").to_repos }
      specify { expect(subject.size).to eq 1 }
    end
  end

  describe "#metadata" do
    subject { repo.new("repo" => "scratch", "tag" => "latest").metadata }
    it { is_expected.to be_a Docker::Template::Metadata }
  end

  describe "#to_env_hash" do
    subject { repo.new("repo" => "scratch", "tag" => "latest").to_env_hash }
    it { is_expected.to be_a Hash }

    RSpec::Helpers.in_data do
      data = { "repo" => "scratch", "tag" => "latest" }
      Docker::Template::Repo.new(data).metadata["env"].as_hash.each do |key, val|
        it { is_expected.to include key => val }
      end
    end

    context "(tar_gz: val)" do
      subject { repo.new("repo" => "scratch", "tag" => "latest").to_env_hash(tar_gz: "val") }
      it { is_expected.to include("TAR_GZ" => "val") }
    end

    context "(copy_dir: val)" do
      subject { repo.new("repo" => "scratch", "tag" => "latest").to_env_hash(copy_dir: "val") }
      it { is_expected.to include "COPY" => "val" }
    end
  end
end
