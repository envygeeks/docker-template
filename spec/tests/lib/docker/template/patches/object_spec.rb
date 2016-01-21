# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Object do
  describe "#to_pathname" do
    it "converts blindly runs Pathutil.new" do
      expect("hello".to_pathname).to be_a Pathutil
    end
  end
end
