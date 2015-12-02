# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe String do
  describe "#to_a" do
    subject { "hello world".to_a }
    it { is_expected.to eq ["hello", "world"] }
  end
end
