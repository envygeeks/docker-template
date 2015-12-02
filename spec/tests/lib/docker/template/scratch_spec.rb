# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Scratch do
  include_context :docker_mocks

  subject { scratch.new(repo) }
  let(:repo) { Docker::Template::Repo.new("repo" => "scratch", "tag" => "latest") }
  let(:scratch) { described_class }

  before do
    allow_any_instance_of(scratch).to receive(:verify_context).and_return nil
    allow_any_instance_of(scratch).to receive(:create_args).and_return({})
    allow_any_instance_of(scratch).to receive( :start_args).and_return({})
  end

  describe "#data" do
    subject { instance.data }
    let(:instance) { scratch.new(repo).tap { |obj| obj.send(:setup_context) }}
    it { is_expected.to match %r!MAINTAINER #{Regexp.escape(repo.metadata["maintainer"])}! }
    it { is_expected.to match %r!^ADD .*\.tar\.gz /$!m }
    it { is_expected.not_to(be_empty) }
    after { instance.unlink }
  end

  describe "#setup_context" do
    before { instance.send(:setup_context) }
    it { is_expected.to include match(/Dockerfile\Z/) }
    subject { instance.instance_variable_get(:@context).children.map(&:to_path) }
    let(:instance) { scratch.new(repo) }
    after { instance.unlink }
  end

  describe "#unlink" do
    before { silence_io { subject.build }}

    context "(img: true)" do
      specify { expect(docker_image_mock).to receive(:delete) }
      after { subject.unlink(img: true) }
    end

    context do
      specify { expect(pathname).to_not exist }
      let(:pathname) { subject.instance_variable_get(:@context) }
      before { subject.unlink }
    end
  end

  describe "#build_context" do
    after do |ex|
      if !ex.metadata[:nobuild]
        subject.send(:build_context)
      end
    end

    it { is_expected.to receive(:build_rootfs) }
    specify { expect(docker_container_mock).to receive :stop }
    specify { expect(docker_container_mock).to receive :delete }
    specify { expect(Docker::Container).to receive :create }
    specify { expect(docker_container_mock).to receive(:attach) }

    context "when nothing logged" do
      before { allow(docker_container_mock).to receive :attach }
      specify { expect(docker_container_mock).to receive(:streaming_logs) }
    end

    context "when an image exists badly" do
      before { allow(docker_container_mock).to receive(:json).and_return("State" => { "ExitCode" => 1 }) }
      specify(nil, :nobuild => true) { expect { subject.send(:build_context) }.to raise_error \
        Docker::Template::Error::BadExitStatus }
    end
  end
end
