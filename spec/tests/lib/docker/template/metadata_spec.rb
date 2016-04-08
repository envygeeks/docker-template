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
    })
  end

  #

  describe "#initialize" do
    context "when given symbol keys" do
      subject do
        data = { :hello => :world }
        described_class.new(
          data
        )
      end

      #

      it "should stringify the metadata" do
        expect(subject).to include({
          "hello" => "world"
        })
      end
    end

    #

    context "when initializing a sub-hash" do
      subject do
        data = { :hello => :world }
        described_class.new(data, :root => described_class.new({
          :world => :hello
        }))
      end

      #

      it "should accept root data if a sub-hash" do
        expect(subject.data).not_to eq(
          subject.root_data
        )
      end
    end
  end

  #

  describe "#_shas" do
    it "should pull the shas from the Gem root" do
      expect(subject._shas).to eq(
        Docker::Template.gem_root.join("shas.yml").read_yaml.stringify
      )
    end
  end

  #

  describe "#root_data" do
    context "when no root data was given" do
      it "should return the data" do
        expect(subject.root_data).to eq(
          subject.data
        )
      end
    end

    #

    context do
      subject do
        described_class.new({ "hello" => "world" }, {
          :root => {
            "world" => "hello"
          }
        })
      end

      #

      it "should return the root data" do
        expect(subject.root_data).not_to eq(
          subject.data
        )
      end
    end
  end

  #

  describe "#root" do
    it "should return a pathname with the root" do
      expect(subject.root).to be_a(
        Pathutil
      )
    end
  end

  #

  describe "#include?" do
    context "when given another hash" do
      it "should verify each pair" do
        expect(subject.include?(:push => false)).to eq(
          true
        )
      end
    end

    #

    it "should stringify" do
      expect(subject.include?(:type => :normal)).to eq(
        true
      )
    end

    #

    context "when not given a hash" do
      it "should behave like normal include" do
        expect(subject.include?(:type)).to eq(
          true
        )
      end
    end
  end

  #

  describe "#[]=" do
    before do
      subject[:hello] = :world
    end

    #

    it "should stringify for normality" do
      expect(subject["hello"]).to eq(
        "world"
      )
    end
  end

  #

  describe "#[]" do
    it "should be able to pull values similar to a hash" do
      expect(subject["hello"]).to eq(
        "world"
      )
    end

    #

    context "when the value is a Hash" do
      before do
        subject.merge!("hello" => {
          "world" => true
        })
      end

      #

      it "should wrap it" do
        expect(subject["hello"]).to be_a(
          described_class
        )
      end
    end

    #

    it "should be indifferent" do
      expect(subject[:hello]).to eq(
        "world"
      )
    end
  end

  #

  describe "#update" do
    before do
      subject.update({
        :hello => :world
      })
    end

    #

    it "should stringify the hash" do
      expect(subject["hello"]).to eq(
        "world"
      )
    end
  end

  #

  shared_examples :merge do
    subject do
      described_class.new({
        #
      })
    end

    #

    context do
      it "should stringify" do
        expect(subject.send(type, :hello => :world)).to include({
          "hello" => "world"
        })
      end
    end

    #

    context "when merging into a queryable array" do
      context "and given non-queryable" do
        before do
          subject.merge!(:hello => { :all => {}})
          subject.merge!({
            :hello => :world
          })
        end

        #

        it "should make the given hash queryable" do
          result = subject.send(type, :hello => { :all => {}})
          result = result .send(type, :hello => :world)
          expect(result[:hello]).to eq(
            "world"
          )
        end
      end
    end
  end

  #

  describe "#merge" do
    let :type do
      :merge
    end

    it_behaves_like(
      :merge
    )
  end

  #

  describe "#merge!" do
    let :type do
      :merge!
    end

    it_behaves_like(
      :merge
    )
  end

  #

  describe "#queryable?" do
    context "when one of the fallback keys are missing" do
      before do
        subject.merge!({
          "hello" => {
            "all" => "hello"
          }
        })
      end

      #

      it "should return true" do
        expect(subject["hello"].queryable?).to eq(
          true
        )
      end
    end

    #

    context "when there are non-fallbackable keys" do
      before do
        subject.merge!({
          "hello" => {
            "all" => "hello", "hello" => "world"
          }
        })
      end

      #

      it "should return false" do
        expect(subject.queryable?).to eq(
          false
        )
      end
    end
  end

  #

  describe "#complex_alias?" do
    before do
      subject.merge!({
        "tag" => "hello",
        "aliases" => {
          "hello" => "default"
        },

        "env" => {
          "tag" => {
            "hello" => {
              "world" => true
            }
          }
        }
      })
    end

    #

    context "when the subject is not an alias" do
      before do
        subject.delete(
          "aliases"
        )
      end

      it "should return false" do
        expect(subject.complex_alias?).to eq(
          false
        )
      end
    end

    #

    context "when the tag is an alias" do
      context "and it also has it's own data" do
        it "should return true" do
          expect(subject.complex_alias?).to eq(
            true
          )
        end
      end

      #

      context "and it doesn't have it's own data" do
        before do
          subject.delete(
            "env"
          )
        end

        specify "it should return false" do
          expect(subject.complex_alias?).to eq(
            false
          )
        end
      end
    end
  end

  #

  describe "#alias?" do
    before do
      subject.merge!({
        "tag" => "hello",
        "aliases" => {
          "hello" => "default"
        }
      })
    end

    #

    it "should return true" do
      expect(subject.alias?).to eq(
        true
      )
    end

    context "when the tag is not an alias" do
      before do
        subject.merge!({
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

  describe "#aliased_tag" do
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
        subject.merge!({
          "tag" => "world"
        })
      end

      #

      it "should return the aliased tags value" do
        expect(subject.aliased_tag).to eq(
          "hello"
        )
      end
    end

    #

    context "when there is no alias" do
      before do
        subject.merge!({
          "tag" => "hello"
        })
      end

      #

      it "should return the current tag" do
        expect(subject.aliased_tag).to eq(
          "hello"
        )
      end
    end
  end

  #

  describe "#to_s" do
    context "when given a mergeable array" do
      before do
        subject.merge!({
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
        })
      end

      #

      context "and :raw => false" do
        it "should merge and convert" do
          expect(subject["env"].to_s).to eq(
            "world hello"
          )
        end
      end

      #

      context "and :raw => true" do
        it "shouldn't merge and convert" do
          expect(subject["env"].to_s(:raw => true)).to(
            eq(subject.data["env"].to_s)
          )
        end
      end
    end

    #

    context "when given a mergable hash" do
      before do
        subject.merge!({
          "tag" => "default",
          "env" => {
            "tag" => {
              "default" => {
                "hello" => "world"
              }
            },

            "all" => {
              "world" => "hello"
            }
          }
        })
      end

      context "and :raw => false" do
        it "should merge and convert" do
          expect(subject["env"].to_s).to eq(
            "world=hello hello=world"
          )
        end
      end

      #

      context "and :raw => true" do
        it "shouldn't merge and convert" do
          expect(subject["env"].to_s(:raw => true)).to(
            eq(subject.data["env"].to_s)
          )
        end
      end
    end

    #

    context "when given something that can fallback" do
      before do
        subject.merge!({
          "hello" => {
            "all" => "hello",
            "tag" => {
              "latest" => "world"
            }
          }
        })
      end

      #

      context "and :raw => false" do
        it "should fallback and convert" do
          expect(subject["hello"].to_s).to eq(
            "world"
          )
        end
      end

      #

      context "and :raw => true" do
        it "shouldn't fallback and convert" do
          expect(subject["hello"].to_s(:raw => true)).to(
            eq(subject.data["hello"].to_s)
          )
        end
      end
    end

    #

    context "when given something that cannot fallback" do
      context "and it's a hash of strings" do
        before do
          subject.merge!({
            "hello" => {
              "world" => "hello"
            }
          })
        end

        #

        context "and :raw => false" do
          it "shouldn't convert" do
            expect(subject["hello"].to_s).to(
              eq(subject.data["hello"].to_s)
            )
          end
        end

        #

        context "and :raw => true" do
          it "shouldn't convert" do
            expect(subject["hello"].to_s(:raw => true)).to(
              eq(subject.data["hello"].to_s)
            )
          end
        end
      end

      #

      context "and it's not a hash full of strings" do
        before do
          subject.merge!({
            "hello" => {
              "world" => %w(
                hello
              )
            }
          })
        end

        #

        it "should not convert" do
          expect(subject["hello"].to_s).to(
            eq(subject.data["hello"].to_s)
          )
        end
      end
    end
  end

  #

  describe "#to_a" do
    context "when given a hash of arrays" do
      before do
        subject.merge!({
          "hello" => {
            "all" => %w(hello),

            "tag" => {
              "latest" => %w(world)
            }
          }
        })
      end

      #

      it "should merge them" do
        expect(subject["hello"].to_a.sort).to eq %w(
          hello world
        )
      end
    end

    #

    context "when given a hash do" do
      context "and it's not a mergeable hash" do
        before do
          subject.merge!({
            "hello" => {
              "world" => true
            }
          })
        end

        #

        it "should make an array of key=val" do
          expect(subject["hello"].to_a).to eq %w(
            world=true
          )
        end
      end

      #

      context "when it's a mergeable hash" do
        before do
          subject.merge!({
            "hello" => {
              "tag" => {
                "latest" => {
                  "hello" => true
                }
              },

              "all" => {
                "world" => true
              }
            }
          })
        end

        #

        it "should merge the hashes and make an array of key=val" do
          expect(subject["hello"].to_a.sort).to eq %w(
            hello=true world=true
          )
        end
      end
    end
  end

  #

  describe "#to_h" do
    before do
      subject.merge!({
        "hello" => {
          "tag" => {
            "latest" => {
              "world" => true
            }
          },

          "all" => {
            "hello" => true
          }
        }
      })
    end

    #

    context "when told to output raw" do
      it "should output without merging" do
        expect(subject["hello"].to_h(:raw => true)).to eq(
          subject.data[
            "hello"
          ]
        )
      end
    end

    #

    it "should merge if the hash is mergeable" do
      expect(subject["hello"].to_h).to eq({
        "hello" => true,
        "world" => true
      })
    end

    #

    context "when given an unmergeable hash" do
      before do
        subject.merge!({
          "hello" => {
            "tag" => {
              "latest" => "world"
            }
          }
        })
      end

      #

      it "should output the raw hash" do
        expect(subject["hello"].to_h).to eq(
          subject.data[
            "hello"
          ]
        )
      end
    end
  end

  #

  describe "#mergeable_hash?" do
    context "when given a fallbackable hash of hashes" do
      before do
        subject.merge!({
          "hello" => {
            "tag" => {
              "latest" => {
                "hello" => true
              }
            },

            "all" => {
              "world" => true
            }
          }
        })
      end

      #

      it "should return true" do
        expect(subject["hello"].mergeable_hash?).to eq(
          true
        )
      end
    end

    #

    context "when given a non-fallbackable hash of hashes" do
      before do
        subject.merge!({
          "hello" => {
            "world" => {
              "hello" => true
            },

            "hello" => {
              "world" => true
            }
          }
        })
      end

      #

      it "should return false" do
        expect(subject["hello"].mergeable_hash?).to eq(
          false
        )
      end
    end

    #

    context "when given a sub-value that is not hash" do
      before do
        subject.merge!({
          "hello" => {
            "world" => [
              "hello=true"
            ],

            "all" => {
              "world" => true
            }
          }
        })
      end

      #

      it "should return false" do
        expect(subject["hello"].mergeable_hash?).to eq(
          false
        )
      end
    end
  end

  #

  describe "#mergeable_array?" do
    context "when given a fallbackable hash of array" do
      before do
        subject.merge!({
          "hello" => {
            "tag" => {
              "latest" => [
                "hello=world"
              ]
            },

            "all" => [
              "world=true"
            ]
          }
        })
      end

      #

      it "should return true" do
        expect(subject["hello"].mergeable_array?).to eq(
          true
        )
      end
    end

    #

    context "when given a non-fallbackable hash of array" do
      before do
        subject.merge!({
          "hello" => {
            "world" => [
              "hello=world"
            ],

            "hello" => [
              "world=true"
            ]
          }
        })
      end

      #

      it "should return true" do
        expect(subject["hello"].mergeable_array?).to eq(
          false
        )
      end
    end

    #

    context "when given a sub-value that is not an array" do
      before do
        subject.merge!({
          "hello" => {
            "world" => true,
            "hello" => [
              "world=true"
            ]
          }
        })
      end

      #

      it "should return true" do
        expect(subject["hello"].mergeable_array?).to eq(
          false
        )
      end
    end
  end

  #

  describe "#fallback" do
    context do
      before do
        subject.merge!({
          "tags" => {
            "latest" => "normal"
          },

          "hello" => {
            "group" => {
              "normal" => "world1"
            }
          }
        })
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
      before do
        subject.merge!({
          "tags" => {
            "latest" => "normal"
          },

          "hello" => {
            "all" => "world3"
          }
        })
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
      before do
        subject.merge!({
          "tags" => {
            "latest" => "normal"
          },

          "hello" => {
            "tag" => {
              "latest" => "world2"
            }
          }
        })
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

  describe "#by_tag" do
    before do
      subject.merge!({
        "hello" => {
          "tag" => {
            "latest" => "world"
          }
        }
      })
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
    before do
      subject.merge!({
        "tags" => {
          "latest" => "normal"
        },

        "hello" => {
          "group" => {
            "normal" => "world"
          }
        }
      })
    end

    #

    it "should pull the data by the tags group" do
      expect(subject["hello"].by_group).to eq(
        "world"
      )
    end
  end

  #

  describe "#tags" do
    before do
      subject["tags"] = {
        "hello" => "world"
      }
    end

    #

    it "should return an array of tags" do
      expect(subject.tags).to eq %w(
        hello
      )
    end

    #

    context "when there are aliases" do
      before do
        subject.merge!({
          "tags" => {
            "hello" => "world"
          },

          "aliases" => {
            "world" => "hello"
          }
        })
      end

      #

      it "should include those" do
        expect(subject.tags.sort).to eq %w(
          hello world
        )
      end
    end

    #

    context do
      before do
        subject.merge!({
          "hello" => {},
          "tags"  => {
            "hello" => "world"
          }
        })
      end

      #

      it "should pull from the root metadata" do
        expect(subject["hello"].tags).to eq %w(
          hello
        )
      end
    end
  end

  #

  describe "#groups" do
    before do
      subject["tags"] = {
        "hello" => "world",
        "world" => "world"
      }
    end

    #

    it "should output an array of groups" do
      expect(subject.groups).to eq %w(
        world
      )
    end

    #

    context do
      before do
        subject.merge!("hello" => {
          #
        })
      end

      #

      it "should pull groups from the root metadata" do
        expect(subject["hello"].groups).to eq %w(
          world
        )
      end
    end
  end

  #

  describe "#try_default" do
    it "should pull from the base configuration" do
      expect(subject[Docker::Template::Metadata::DEFAULTS.keys.first]).to eq(
        Docker::Template::Metadata::DEFAULTS.values.first
      )
    end
  end

  #

  describe "#merge_or_override" do
    subject do
      described_class.new({
        #
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

  describe "#string_wrapper" do
    context "when given an array" do
      it "should join those values to a string" do
        expect(subject.send(:string_wrapper, %w(hello world))).to eq(
          "hello world"
        )
      end
    end

    #

    context "when given another object" do
      it "should run to_s" do
        expect(subject).to receive(
          :to_s
        )
      end

      #

      after do
        subject.send(
          :string_wrapper, subject
        )
      end
    end
  end

  #

  describe "#method_missing" do
    context do
      before do
        subject.merge!({
          "hello" => :world
        })
      end

      #

      it "should call to_s unless boolean" do
        expect(subject["hello"]).to receive(
          :to_s
        )
      end

      #

      after do
        subject.hello
      end
    end

    #

    context "when a method contains ?" do
      it "should make it a boolean" do
        expect(subject.hello?).to eq(
          true
        )
      end
    end
  end
end
