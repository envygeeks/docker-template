# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Hash do
  subject { hash }
  let :hash do
    {
      :hello => :world,
      :world => :hello
    }
  end

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

    specify do
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

  describe "#stringify_keys" do
    subject { hash.stringify_keys }
    it { is_expected.to eq "hello" => :world, "world" => :hello }
  end

  describe "#any_keys?" do
    subject { hash.any_keys?(:hello, :world) }
    it { is_expected.to eq true }

    context "with an invalid key" do
      subject { hash.any_keys?(:invalid, :hello) }
      it { is_expected.to eq true }
    end
  end

  describe "#leftover_keys?" do
    subject { hash.leftover_keys?(:hello) }
    it { is_expected.to eq true }

    context "when all keys are tapped" do
      subject { hash.leftover_keys?(:hello, :world) }
      it { is_expected.to eq false }
    end
  end

  describe "keys?" do
    subject { hash.keys?(:hello) }
    it { is_expected.to eq true }

    context "with an invalid key" do
      subject { hash.keys?(:invalid, :world) }
      it { is_expected.to eq false }
    end
  end

  describe "#to_env_ary" do
    subject { hash.to_env_ary }
    it { is_expected.to eq ["hello=world", "world=hello"] }
  end

  describe "#deep_merge" do
    specify do
      hash1 = { :hello => { :world1 => 1 }}
      hash2 = { :hello => {
        :world2 => 2
      }}

      result = hash1.deep_merge(hash2)
      expect(result[:hello]).to include({
        :world2 => 2
      })
    end

    specify do
      hash1 = { :hello => { :world => 1 }}
      hash2 = {
        :hello => :world
      }

      result = hash1.deep_merge(hash2)
      expect(result[:hello]).to eq :world
    end
  end
end
