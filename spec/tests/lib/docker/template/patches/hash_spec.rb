# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

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

  describe "#any_keys?" do
    it "should be true if all keys exist" do
      expect(subject.any_keys?(:hello, :world)).to eq(
        true
      )
    end

    #

    context "with an invalid key" do
      it "should still return true if one key exists" do
        expect(hash.any_keys?(:invalid, :hello)).to eq(
          true
        )
      end
    end
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
