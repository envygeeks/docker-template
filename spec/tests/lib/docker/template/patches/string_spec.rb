# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe String do
  describe "#to_a" do
    it "splits by spaces and returns the result as an array" do
      expect("hello world".to_a).to eq %W(hello world)
    end
  end
end
