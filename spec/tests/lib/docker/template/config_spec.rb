# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Config do
  let(:config) { Docker::Template.config }
  describe "#initialize" do
    Docker::Template::Config::DEFAULTS.each do |key, _|
      it { is_expected.to have_key key }
    end
  end

  describe "#read_config_from" do
    let(:repo_root) { Docker::Template.repos_root }
    it { is_expected.to eq "maintainer" => "Some Girl <lyfe@thug.programmer>" }
    subject { config.read_config_from(path) }
    let(:path) { repo_root.join("config") }

    context "when empty" do
      let(:path) { repo_root.join("empty") }
      subject { config.read_config_from(path) }
      it { is_expected.to be_a Hash }
    end

    context "when non-existant" do
      let(:path) { Pathname.new("bad_file") }
      subject { config.read_config_from(path) }
      it { is_expected.to be_a Hash }
    end

    context "when invalid" do
      let(:path) { repo_root.join("invalid") }
      let(:error) { Docker::Template::Error::InvalidYAMLFile }
      specify { expect(&subject).to raise_error error }
      subject { -> { config.read_config_from(path) }}
    end
  end

  describe "#build_types" do
    subject { config.build_types }
    it { is_expected.to be_an Array }
  end

  describe "#has_default?" do
    subject { config.has_default?("user") }
    it { is_expected.to eq true }

    context "with a non-existant key" do
      subject { config.has_default?("hello") }
      it { is_expected.to eq false }
    end
  end

  it { is_expected.to respond_to :keys }
  it { is_expected.to respond_to :to_h }
  it { is_expected.to respond_to :to_enum }
  it { is_expected.to respond_to :key? }
  it { is_expected.to respond_to :each }
  it { is_expected.to respond_to :[] }
end
