# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "rspec/helper"
describe Docker::Template::Metadata do
  subject do
    described_class.new({
      "hello" => "world"
    }, root: true)
  end

  #

  it "should raise if root: false and !root_metadata" do
    expect { described_class.new({}) }.to raise_error(
      Docker::Template::Error::NoRootMetadata
    )
  end

  #

  describe "#[]" do
    it "should be able to pull values similar to a hash" do
      expect(subject["hello"]).to eq(
      "world"
      )
    end

    #

    it "should be indifferent" do
      expect(subject[:hello]).to eq(
        "world"
      )
    end
  end

  #

  describe "#to_gem_version" do
    subject do
      described_class.new({
        "name" => "hello",
        "versions" => {
          "all" => "3.2"
        }
      }, root: true)
    end

    #

    it "should merge repo with version" do
      expect(subject.to_gem_version).to eq(
        "hello@3.2"
      )
    end
  end

  #

  describe "#from_root" do
    subject do
      described_class.new({
        "hello" => {
          "world" => "how are you?"
        }
      }, root: true)
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
      described_class.new({
        "hello" => {
          "tag" => {
            "latest" => "world"
          }
        }
      }, root: true)
    end

    #

    it "should query by that tag key" do
      expect(subject["hello"].by_tag).to eq(
        "world"
      )
    end
  end

  #

  describe "#by_group" do
    subject do
      described_class.new({
        "tags" => {
          "latest" => "normal"
        },

        "hello" => {
          "group" => {
            "normal" => "world"
          }
        }
      }, root: true)
    end

    #

    it "should query by that group key" do
      expect(subject["hello"].by_group).to eq(
        "world"
      )
    end
  end

  #

  describe "#for_all" do
    subject do
      described_class.new({
        "hello" => {
          "all" => "world"
        }
      }, root: true)
    end

    #

    it "should query by that all key" do
      expect(subject["hello"].for_all).to eq(
        "world"
      )
    end
  end

  #

  describe "#to_set" do
    subject do
      described_class.new({
        "tags" => { "latest" => "normal" }, "hello" => {
          "tag"   => { "latest" => "person" },
          "group" => { "normal" =>  "world" },
          "all"   => "everyone"
        }
      }, root: true)
    end

    #

    specify { expect(subject["hello"].to_set).to include "person" }
    specify { expect(subject["hello"].to_set).to include "everyone" }
    specify { expect(subject["hello"].to_set).to include "world" }
  end

  #

  describe "#to_h" do
    context "when given a parent hash" do
      subject do
        described_class.new({}, root_metadata: {
          "hello" => "world"
        })
      end

      #

      it "should not include the parent hash" do
        expect(subject.to_h).to eq({
          #
        })
      end
    end

    #

    subject do
      described_class.new({
        "tags" => {
          "latest" => "normal"
        },

        "hello" => {
          "group" => {
            "normal" => {
              "world"  => "hello"
            }
          },

          "tag" => {
            "latest" => {
              "person" => "hello"
            }
          },

          "all" => {
            "everyone" => "hello"
          }
        }
      }, root: true)
    end

    #

    context "when there are more keys than tag, group, all" do
      it "should revert to normal to_h" do
        expect(subject.to_h).to eq(
          subject.instance_variable_get(:@metadata)
        )
      end
    end

    #

    specify do
      expect(subject["hello"].to_h).to \
      include({
        "person" => "hello"
      })
    end

    #

    specify do
      expect(subject["hello"].to_h).to \
      include({
        "everyone" => "hello"
      })
    end

    #

    specify do
      expect(subject["hello"].to_h).to \
      include({
        "world" => "hello"
      })
    end
  end

  #

  describe "#fallback" do
    context do
      subject do
        described_class.new({
          "tags" => {
            "latest" => "normal"
          },

          "hello" => {
            "group" => {
              "normal" => "world1"
            }
          }
        }, root: true)
      end

      #

      it "should return group if no tag is available" do
        expect(subject["hello"].fallback).to eq(
          "world1"
        )
      end
    end

    #

    context do
      subject do
        described_class.new({
          "tags" => {
            "latest" => "normal"
          },

          "hello" => {
            "all" => "world3"
          }
        }, root: true)
      end

      #

      it "should return all when no tag or group is available" do
        expect(subject["hello"].fallback).to eq(
          "world3"
        )
      end
    end

    #

    context do
      subject do
        described_class.new({
          "tags" => {
            "latest" => "normal"
          },

          "hello" => {
            "tag" => {
              "latest" => "world2"
            }
          }
        }, root: true)
      end

      #

      it "should return tag" do
        expect(subject["hello"].fallback).to eq(
          "world2"
        )
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
      }, root: true)
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
        expect(subject.aliased).to eq(
          "hello"
        )
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
        expect(subject.aliased).to eq(
          "hello"
        )
      end
    end
  end

  #

  describe "#alias?" do
    before do
      subject.merge({
        "aliases" => { "hello" => "default" },
        "tag" => "hello"
      })
    end

    #

    it "should return true" do
      expect(subject.alias?).to eq(
        true
      )
    end

    context "when the tag is not in the aliases field" do
      before do
        subject.merge({
          "tag" => "default"
        })
      end

      #

      it "should return false" do
        expect(subject.alias?).to eq(
          false
        )
      end
    end
  end

  #

  describe "#complex_alias?" do
    before do
      subject.merge({
        "aliases" => { "hello" => "default" },
        "tag" => "hello",
        "env" => {
          "tag" => {
            "hello" => {
              "world" => "true"
            }
          }
        }
      })
    end

    #

    it "should return true" do
      expect(subject.complex_alias?).to eq(
        true
      )
    end
  end

  #

  describe "#tags" do
    subject do
      described_class.new({
        "tags" => {
          "hello" => "world"
        }
      }, root: true)
    end

    #

    it "should return an array of tags" do
      expect(subject.tags).to eq [
        "hello"
      ]
    end
  end

  #

  describe "#merge" do
    subject do
      described_class.new({}, {
        :root => true
      })
    end

    #

    context do
      before do
        subject.merge({
          :hello => :world
        })
      end

      #

      it "should stringify stuff" do
        expect(subject.instance_variable_get(:@metadata)).to eq({
          "hello" => "world"
        })
      end
    end

    #

    describe "#to_env" do
      subject do
        described_class.new({ "hello" => "world" }, {
          :root => true
        })
      end

      context "when given an array" do
        subject do
          described_class.new({ "hello" => ["world"] }, {
            :root => true
          })
        end

        #

        it "should join the array" do
          expect(subject.to_env.to_h).to eq({
            "HELLO" => "world"
          })
        end
      end

      #

      context "when given hashes" do
        subject do
          described_class.new({ "world" => { "hello" => "you" }}, {
            :root => true
          })
        end

        #

        it "should collapse them" do
          expect(subject.to_env.to_h).to eq({
            "HELLO" => "you"
          })
        end
      end

      #

      it "should capitalize all the keys" do
        expect(subject.to_env.to_h).to eq({
          "HELLO" => "world"
        })
      end

      #

      it "should return a metadata" do
        expect(subject.to_env).to be_a(
          described_class
        )
      end
    end

    #

    context "when at the root level" do
      it "should also merge to root too" do
        expect(subject.instance_variable_get(:@root_metadata)).to eq(
          subject.instance_variable_get(
            :@metadata
          )
        )
      end
    end
  end

  #

  describe "#to_env_ary" do
    it "should run #to_env and make it an array" do
      expect(subject.to_env_ary).to eq [
        "HELLO=world"
      ]
    end
  end

  #

  describe "#to_env_str" do
    it "should create a string from the hash" do
      expect(subject.to_env_str).to eq(
        "HELLO=world"
      )
    end

    #

    context "when told to make it multiline" do
      subject do
        described_class.new({ "hello" => "world", "world" => "hello" }, {
          :root => true
        })
      end

      #

      it "should split it up" do
        expect(subject.to_env_str(:multiline => true)).to eq(
          "HELLO=world \\\n  WORLD=hello"
        )
      end
    end
  end

  #

  describe "#to_s" do
    context "when given a mergeable array" do
      let :hash do
        {
          "tag" => "default",
          "env" => {
            "tag" => {
              "default" => [
                "hello"
              ]
            },

            "all" => [
              "world"
            ]
          }
        }
      end

      subject do
        described_class.new(hash, {
          :root => true
        })
      end

      #

      it "should merge the array" do
        expect(subject["env"].to_s).to eq(
          "world hello"
        )
      end
    end

    #

    context "when given a mergable hash" do
      let :hash do
        {
          "tag" => "default",
          "env" => {
            "tag" => {
              "default" => {
                "hello" => "world"
              },

              "all" => {
                "world" => "hello"
              }
            }
          }
        }
      end

      #

      subject do
        described_class.new(hash, {
          :root => true
        })
      end

      it "should merge the hash" do
        expect(subject["env"].to_s).to eq(
          "HELLO=world WORLD=hello"
        )
      end
    end
  end

  #

  describe "#merge_or_override" do
    subject do
      described_class.new({}, {
        :root => true
      })
    end

    #

    def isend(*vals)
      subject.send(
        :merge_or_override, *vals
      )
    end

    #

    context "[1], '2'" do
      context "with two different unmergable types" do
        it "should return the original value" do
          expect(isend([1], "2")).to eq(
            [1]
          )
        end
      end
    end

    #

    context "'1', [2]" do
      context "with two different unmergable types" do
        it "should return the original value" do
          expect(isend("1", [2])).to eq(
            "1"
          )
        end
      end
    end

    #

    context "nil, [1]" do
      context "when the old val is nil" do
        it "should return the original value" do
          expect(isend(nil, [1])).to eq([
            1
          ])
        end
      end
    end

    #

    context "[1], nil" do
      context "when the new val is nil" do
        it "should return the original value" do
          expect(isend([1], nil)).to eq([
            1
          ])
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

  #

  describe "#aliased" do
    before do
      subject.merge({
        "aliases" => {
          "hello" => "default"
        },

        "tag" => "hello",

        "env" => {
          "tag" => {
            "hello" => {
              "world" => "true"
            }
          }
        }
      })
    end

    #

    it "should pull the parent tag" do
      expect(subject.aliased).to eq(
        "default"
      )
    end

    #

    context "when in a sub-metadata" do
      it "should pull from root" do
        expect(subject["env"].aliased).to eq(
          "default"
        )
      end
    end
  end
end
