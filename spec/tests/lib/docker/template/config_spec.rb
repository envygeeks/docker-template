# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Config do
  let(:config) { Docker::Template.config }
  describe "#initialize" do
    Docker::Template::Config::Defaults.each do |key, _|
      it { is_expected.to have_key key }
    end
  end

  describe "#read_config_from" do
    subject { config.read_config_from(Docker::Template.repos_root.join("config")) }
    it { is_expected.to eq "maintainer" => "Some Girl <lyfe@thug.programmer>" }

    context "with a bad file" do
      subject { config.read_config_from(Pathname.new("bad_file")) }
      it { is_expected.to be_a Hash }
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
