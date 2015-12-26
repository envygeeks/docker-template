# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Hash do
  subject do
    hash
  end

  #

  let :hash do
    {
      :hello => :world,
      :world => :hello
    }
  end

  #

  describe "#stringify" do
    let :hash do
      {
        :hello => :world,
        :world => [
          :animal,
          :kingdom,
          {
            :and => :other_stuff
          }
        ],

        :other => {
          :planets => :have_life
        }
      }
    end

    #

    it "should stringify the hash" do
      expect(subject.stringify).to eq({
        "hello" => "world",
        "world" => [
          "animal",
          "kingdom",
          {
            "and" => "other_stuff"
          }
        ],

        "other" => {
          "planets" => "have_life"
        }
      })
    end
  end

  #

  describe "#stringify_keys" do
    it "converts keys that support it to strings" do
      expect(subject.stringify_keys).to eq({
        "hello" => :world, "world" => :hello
      })
    end
  end

  #

  describe "#any_keys?" do
    it "should be true if all keys exist" do
      expect(subject.any_keys?(:hello, :world)).to eq true
    end

    #

    context "with an invalid key" do
      it "should still return true if one key exists" do
        expect(hash.any_keys?(:invalid, :hello)).to eq true
      end
    end
  end

  #

  describe "#leftover_keys?" do
    it "should return true if there are any keys after removing the key" do
      expect(hash.leftover_keys?(:hello)).to eq true
    end

    #

    context "when all keys are tapped" do
      it "should return false" do
        expect(hash.leftover_keys?(:hello, :world)).to eq false
      end
    end
  end

  #

  describe "keys?" do
    it "should accept a single key, like #key?" do
      expect(hash.keys?(:hello))
    end

    #

    context "with a single invalid key" do
      it "should return false" do
        expect(hash.keys?(:invalid, :hello, :world)).to eq false
      end
    end
  end

  #

  describe "#to_env_ary" do
    subject { hash.to_env_ary }
    it { is_expected.to eq ["hello=world", "world=hello"] }
  end

  #

  describe "#deep_merge" do
    it "should handle hashception" do
      hash1 = { :hello => { :world1 => 1 }}
      hash2 = { :hello => {
        :world2 => 2
      }}

      result = hash1.deep_merge(hash2)
      expect(result[:hello]).to include({
        :world2 => 2
      })
    end
  end
end
