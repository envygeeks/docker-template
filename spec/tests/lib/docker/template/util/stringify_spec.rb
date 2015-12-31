# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Util::Stringify do
  describe "#hash" do
    it "should convert various keys" do
      expect(subject.hash(1 => "a", Docker => "b", 0.1 => "c")).to eq({
        "1" => "a",
        "Docker" => "b",
        "0.1" => "c"
      })
    end

    it "should convert values" do
      expect(subject.hash("1" => :a, "2" => Docker, "3" => 0.1)).to eq({
        "1" => "a",
        "2" => "Docker",
        "3" => "0.1"
      })
    end
  end

  describe "#array" do
    it "should convert various keys" do
      expect(subject.array([0.1, Docker, 1])).to eq [
        "0.1", "Docker", "1"
      ]
    end
  end
end
