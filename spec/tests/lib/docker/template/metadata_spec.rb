# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Metadata do
  subject { metadata.new("hello" => "world") }
  specify { expect(subject["hello"]).to eq "world" }
  let(:metadata) { described_class }

  describe "#to_h" do
    context "when given a parent hash" do
      subject { metadata.new({}, :hello => :world).to_h }
      it { is_expected.to eq({}) }
    end
  end

  describe "#from_root" do
    subject { instance["hello"].from_root("hello").to_h }
    let(:instance) { metadata.new("hello" => { "world" => "how are you?" }) }
    it { is_expected.to eq instance["hello"].to_h }
  end

  describe "#by_tag" do
    let :instance do
      metadata.new("hello" => {
        "tag" => {
          "latest" => "world"
        }
      })
    end

    subject { instance["hello"].by_tag }
    it { is_expected.to eq "world" }
  end

  describe "#by_type" do
    let :instance do
      metadata.new("tags" => { "latest" => "normal" }, "hello" => {
        "type" => {
          "normal" => "world"
        }
      })
    end

    subject { instance["hello"].by_type }
    it { is_expected.to eq "world" }
  end

  describe "#for_all" do
    subject { instance["hello"].for_all }
    let(:instance) { metadata.new("hello" => { "all" => "world" }) }
    it { is_expected.to eq "world" }
  end

  describe "#as_set" do
    let :instance do
      metadata.new("tags" => { "latest" => "normal" }, "hello" => {
        "type" => { "normal" =>  "world" },
         "tag" => { "latest" => "person" },
         "all" => "everyone"
      })
    end

    subject { instance["hello"].as_set }
    it { is_expected.to include   "person" }
    it { is_expected.to include "everyone" }
    it { is_expected.to include    "world" }
  end

  describe "#as_string_set" do
    let :instance do
      metadata.new("tags" => { "latest" => "normal" }, "hello" => {
        "type" => { "normal" =>  "world" },
         "tag" => { "latest" => "person" },
         "all" => "everyone"
      })
    end

    subject { instance["hello"].as_string_set }
    it { is_expected.to eq "everyone world person" }
  end

  describe "#as_hash" do
    let :instance do
      metadata.new({
        "tags" => {
          "latest" => "normal"
        },

        "hello" => {
          "type" => {   "normal" => { "world"  => "hello" }},
           "tag" => {   "latest" => { "person" => "hello" }},
           "all" => { "everyone" => "hello" }
        }
      })
    end


    subject { instance["hello"].as_hash }
    it { is_expected.to include   "person" => "hello" }
    it { is_expected.to include "everyone" => "hello" }
    it { is_expected.to include    "world" => "hello" }
  end

  describe "#fallback" do
    subject do
      metadata.new({
        "tags" => {
          "latest" => "normal"
        },

        "hello" => {
          "type" => {   "normal" => "world1" },
           "tag" => {   "latest" => "world2" },
           "all" => "world3"
        }
      })
    end

    specify do
      subject["hello"].delete("type")
      subject["hello"].delete( "tag")
      expect(subject["hello"].fallback).to eq("world3")
    end

    specify do
      subject["hello"].delete("tag")
      subject["hello"].delete("all")
      expect(subject["hello"].fallback).to eq("world1")
    end

    specify do
      subject["hello"].delete("type")
      subject["hello"].delete( "all")
      expect(subject["hello"].fallback).to eq("world2")
    end
  end

  describe "#aliased" do
    let :instance do
      metadata.new({
        "tags" => {
          "hello" => "world"
        },

        "aliases" => {
          "world" => "hello"
        }
      })
    end

    subject { instance.merge({ "tag" => "world" }).aliased }
    it { is_expected.to eq "hello" }

    context "when there is no alias" do
      subject { instance.merge({ "tag" => "hello" }).aliased }
      it { is_expected.to eq "hello" }
    end
  end

  describe "#tags" do
    subject { metadata.new("tags" => { "hello" => "world" }).tags }
    it { is_expected.to eq ["hello"] }
  end
end
