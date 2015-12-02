# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Object do
  describe "#to_pathname" do
    subject { "hello".to_pathname }
    it { is_expected.to be_a Pathname }
  end
end
