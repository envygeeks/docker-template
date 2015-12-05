# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Simple do
  include_context :docker_mocks

  let(:simple) { described_class }
  let(:repo) { in_data { Docker::Template::Repo.new("repo" => "simple", "tag" => "latest")}}
  subject { simple.new(repo) }

  describe "#unlink" do
    specify { expect(subject.instance_variable_get(:@context)).not_to exist }
    before { silence_io { subject.build }}

    context "when dockerhub_cache = true" do
      before { the_metadata["dockerhub_cache"] = true }
      let(:the_metadata) { repo.metadata.instance_variable_get(:@metadata) }
      it { expect(Docker::Template::Util).to receive :create_dockerhub_context }
      after { the_metadata["dockerhub_cache"] = false}
      after { subject.unlink }
    end

    context "(img: true)" do
      after { subject.unlink(img: true) }
      specify { expect(docker_image_mock).to receive :delete }
    end
  end

  describe "#setup_context" do
    before { instance.send(:setup_context) }
    it { is_expected.to include match(/Dockerfile\Z/) }
    subject { instance.instance_variable_get(:@context).children.map(&:to_path) }
    let(:instance) { simple.new(repo) }
    after { instance.unlink }
  end

  describe "#copy_dockerfile" do
    let :instance do
      simple.new(repo).tap do |obj|
        obj.send(:setup_context)
        obj.send(:copy_dockerfile)
      end
    end

    after { instance.unlink }
    subject { instance.instance_variable_get(:@context).join("Dockerfile").read }
    it { is_expected.to eq "latest\n" }
  end
end
