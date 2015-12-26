# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Ansi do
  describe "#clear" do
    subject do
      capture_io do
        described_class.clear
      end
    end

    #

    it "gives ansi to clear the screen", :clear do
      expect(described_class.has?(subject[:stdout])).to be_truthy
    end
  end

  #

  Docker::Template::Ansi::COLORS.keys.map do |color|
    it "should have the color #{color}" do
      expect(subject).to respond_to color
    end
  end

  #

  describe "#clear_line" do
    it "gives ansi to clear the line" do
      expect(subject.has?(subject.clear_line("hello"))).to be_truthy
    end
  end

  #

  describe "#has?" do
    it "should detect ansi" do
      expect(subject.blue("hello")).to be_truthy
    end
  end

  #

  describe "#strip" do
    it "should strip ansi" do
      expect(subject.strip(subject.red("hello"))).to eq "hello"
    end

    #

    context "with reset" do
      it "should strip the reset too" do
        expect(subject.strip(subject.red(subject.reset("hello")))).to eq "hello"
      end
    end

    #

    context "with multiple colors" do
      it "should strip it all" do
        expect(subject.strip(subject.red(subject.yellow("hello")))).to eq "hello"
      end
    end
  end

  #

  describe "#jump" do
    it "should give ansi to jump up and down" do
      expect(subject.jump("hello", 1024)).to match %r!\[1024A|\[1024B\Z!
    end
  end
end
