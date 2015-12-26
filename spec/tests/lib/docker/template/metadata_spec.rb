# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Metadata do
  subject do
    described_class.new({
      "hello" => "world"
    })
  end

  #

  it "should be able to pull values similar to a hash" do
    expect(subject["hello"]).to eq "world"
  end

  #

  describe "#as_gem_version" do
    subject do
      described_class.new({
        "repo" => "hello",
        "versions" => {
          "all" => "3.2"
        }
      })
    end

    #

    it "should merge repo with version" do
      expect(subject.as_gem_version).to eq "hello@3.2"
    end
  end

  #

  describe "#to_h" do
    context "when given a parent hash" do
      subject do
        described_class.new({}, {
          :hello => :world
        })
      end

      #

      it "should not include the parent hash" do
        expect(subject.to_h).to eq({})
      end
    end
  end

  #

  describe "#from_root" do
    subject do
      described_class.new({
        "hello" => {
          "world" => "how are you?"
        }
      })
    end

    #

    it "should return the parent hash" do
      expect(subject["hello"].from_root("hello").to_h).to eq({
        "world" => "how are you?"
      })
    end
  end

  #

  describe "#by_tag" do
    subject do
      described_class.new("hello" => {
        "tag" => {
          "latest" => "world"
        }
      })
    end

    #

    it "should query by that tag key" do
      expect(subject["hello"].by_tag).to eq "world"
    end
  end

  #

  describe "#by_type" do
    subject do
      described_class.new({
        "tags" => {
          "latest" => "normal"
        },
        "hello" => {
          "type" => {
            "normal" => "world"
          }
        }
      })
    end

    #

    it "should query by that type key" do
      expect(subject["hello"].by_type).to eq "world"
    end
  end

  #

  describe "#for_all" do
    subject do
      described_class.new("hello" => {
        "all" => "world"
      })
    end

    #

    it "should query by that all key" do
      expect(subject["hello"].for_all).to eq "world"
    end
  end

  #

  describe "#as_set" do
    subject do
      described_class.new("tags" => { "latest" => "normal" }, "hello" => {
        "type" => { "normal" =>  "world" },
         "tag" => { "latest" => "person" },
         "all" => "everyone"
      })
    end

    #

    specify { expect(subject["hello"].as_set).to include   "person" }
    specify { expect(subject["hello"].as_set).to include "everyone" }
    specify { expect(subject["hello"].as_set).to include    "world" }
  end

  #

  describe "#as_string_set" do
    subject do
      described_class.new("tags" => { "latest" => "normal" }, "hello" => {
        "type" => { "normal" =>  "world" },
         "tag" => { "latest" => "person" },
         "all" => "everyone"
      })
    end

    #

    it "should return a set combined as a string" do
      expect(subject["hello"].as_string_set).to eq \
        "everyone world person"
    end
  end

  #

  describe "#as_hash" do
    subject do
      described_class.new({
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

    #

    specify { expect(subject["hello"].as_hash).to include   "person" => "hello" }
    specify { expect(subject["hello"].as_hash).to include "everyone" => "hello" }
    specify { expect(subject["hello"].as_hash).to include    "world" => "hello" }
  end

  #

  describe "#fallback" do
    subject do
      described_class.new({
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

    #

    context do
      before do
        subject["hello"].delete("tag")
        subject["hello"].delete("all")
      end

      #

      it "should return type if no tag is available" do
        expect(subject["hello"].fallback).to eq "world1"
      end
    end

    #

    context do
      before do
        subject["hello"].delete("type")
        subject["hello"].delete( "tag")
      end

      #

      it "should return all when no tag or type is available" do
        expect(subject["hello"].fallback).to eq "world3"
      end
    end

    #

    context do
      before do
        subject["hello"].delete("type")
        subject["hello"].delete( "all")
      end

      #

      it "should return tag" do
        expect(subject["hello"].fallback).to eq "world2"
      end
    end
  end

  #

  describe "#aliased" do
    subject do
      described_class.new({
        "tags" => {
          "hello" => "world"
        },

        "aliases" => {
          "world" => "hello"
        }
      })
    end

    #

    context do
      before do
        subject.merge({
          "tag" => "world"
        })
      end

      #

      it "should return the aliased tags value" do
        expect(subject.aliased).to eq "hello"
      end
    end

    #

    context "when there is no alias" do
      before do
        subject.merge({
          "tag" => "hello"
        })
      end

      #

      it "should just return the current tag" do
        expect(subject.aliased).to eq "hello"
      end
    end
  end

  #

  describe "#tags" do
    subject do
      described_class.new("tags" => {
        "hello" => "world"
      })
    end

    #

    it "should return an array of tags" do
      expect(subject.tags).to eq [
        "hello"
      ]
    end
  end

  describe "#merge_or_override" do
    subject do
      described_class.new({}, {})
    end

    #

    def isend(*vals)
      subject.send :merge_or_override, *vals
    end

    #

    context "[1], '2'" do
      context "with two different unmergable types" do
        it "should return the original value" do
          expect(isend([1], "2")).to eq [1]
        end
      end
    end

    #

    context "'1', [2]" do
      context "with two different unmergable types" do
        it "should return the original value" do
          expect(isend("1", [2])).to eq "1"
        end
      end
    end

    #

    context "nil, [1]" do
      context "when the old val is nil" do
        it "should return the original value" do
          expect(isend(nil, [1])).to eq [1]
        end
      end
    end

    #

    context "[1], nil" do
      context "when the new val is nil" do
        it "should return the original value" do
          expect(isend([1], nil)).to eq [1]
        end
      end
    end

    #

    context "[1], [2]" do
      context "when the two values are mergeable" do
        specify { expect(isend([1], [2])).to include 2 }
        specify { expect(isend([1], [2])).to include 1 }
      end
    end

    #

    context "{ 1 => 1}, { 2 => 2}" do
      context "when the two values are mergeable" do
        specify { expect(isend({ 1 => 1 }, { 2 => 2 })).to include 2 => 2 }
        specify { expect(isend({ 1 => 1 }, { 2 => 2 })).to include 1 => 1 }
      end
    end
  end
end
