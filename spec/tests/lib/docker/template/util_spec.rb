# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Util do
  let(:util) { described_class }

  describe "#notify_alias" do
    let(:repo) { Docker::Template::Repo.new("repo" => "scratch", "tag" => "alias") }
    specify { expect(subject[:stdout]).to match %r!aliasing [a-z]+/[a-z]+:[a-z]+ -> [a-z]+/[a-z]+:[a-z]+!i }
    specify { expect(Docker::Template::Ansi.has?(subject[:stdout])).to eq true }
    let(:builder) { Docker::Template::Scratch.new(repo) }
    subject { capture_io { util.notify_alias(builder) }}
  end

  describe "#notify_build" do
    let(:repo) { Docker::Template::Repo.new("repo" => "simple") }
    it { is_expected.to include :stdout => %r!building:[:a-z\s]+/simple:latest!i }
    subject { capture_io { util.notify_build(repo) }}

    context "(rootfs: true)" do
      subject { capture_io { util.notify_build(repo, rootfs: true) }}
      it { is_expected.to include :stdout => %r!building[:a-z\s]+/rootfs:simple!i }
    end
  end

  describe "#create_dockerhub_context" do
    let(:context) { builder.instance_variable_get(:@context) }
    after { builder.repo.root.join(repo.metadata["dockerhub_cache_dir"]).rmtree rescue true; builder.unlink }
    before { builder.send(:copy_build_and_verify); silence_io { util.create_dockerhub_context(builder, context) }}
    let(:repo) { Docker::Template::Repo.new("repo" => "simple", "tag" => "latest") }
    subject { builder.repo.root.join(repo.metadata["dockerhub_cache_dir"], builder.repo.tag) }
    let(:builder) { Docker::Template::Simple.new(repo) }

    it { is_expected.to exist }
    specify { expect(subject.children.map(&:basename).map(&:to_path)).to eq \
      context.children.map(&:basename).map(&:to_path) }
  end
end
