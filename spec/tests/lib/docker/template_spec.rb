# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template do
  it { is_expected.to respond_to :config }
  it { is_expected.to respond_to :repos_root }
  it { is_expected.to respond_to :template_root }
  it { is_expected.to respond_to :gem_root }
  it { is_expected.to respond_to :root }
  it { is_expected.to respond_to :get }
  let(:template) { described_class }

  describe "#repo_is_root?" do
    subject { template.repo_is_root? }
    it { is_expected.to eq true }
    before do
      # "/non-existant" mocks "../../repos" not existing.
      allow(template.root).to receive(:join).with(template.config["repos_dir"]).and_return Pathname.new("/non-existant")
      allow(template.root).to receive(:join).with("copy").and_return Pathname.new("/")
    end
  end

  describe "#repo_root_for" do
    subject { template.repo_root_for("simple") }
    it { is_expected.to eq template.root }
    before do
      # "/non-existant" mocks "../../repos" not existing.
      allow(template.root).to receive(:join).with(template.config["repos_dir"]).and_return Pathname.new("/non-existant")
      allow(template.root).to receive(:join).with("copy").and_return Pathname.new("/")
    end
  end

  describe "#gem_root" do
    subject { template.gem_root }
    it { is_expected.to be_a Pathname }
  end

  describe "#template_root" do
    subject { template.repos_root }
    it { is_expected.to be_a Pathname }
  end

  describe "#config" do
    subject { template.config }
    it { is_expected.to be_a Docker::Template::Config }
  end

  describe "#repos_root" do
    subject { template.repos_root }
    it { is_expected.to be_a Pathname }
  end

  describe "#root" do
    subject { template.root }
    it { is_expected.to be_a Pathname }
  end

  describe "#get" do
    context "when no data is given" do
      subject { template.get(:rootfs) }
      it { is_expected.to be_a String }
    end

    context "when data is given" do
      subject { template.get(:rootfs, :rootfs_base_img => "hello world") }
      it { is_expected.to start_with "FROM hello world\n" }
    end
  end
end
