# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Ansi do
  let :ansi do
    described_class
  end

  #

  describe "#clear" do
    subject do
      capture_io do
        ansi.clear
      end
    end

    it "gives ansi to clear the screen", :clear do
      expect(ansi.has?(subject[:stdout])).to be_truthy
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
    subject do
      ansi.clear_line("hello")
    end

    it "gives ansi to clear the line" do
      expect(ansi.has?(subject)).to be_truthy
    end
  end

  #

  describe "#has?" do
    subject do
      ansi.has?(ansi.blue("hello"))
    end

    it "should detect ansi" do
      expect(subject).to be_truthy
    end
  end

  #

  describe "#strip" do
    subject do
      ansi.strip(ansi.red("hello"))
    end

    it "should strip ansi" do
      expect(subject).to eq "hello"
    end

    context "with reset" do
      subject do
        ansi.strip(ansi.red(ansi.reset("hello")))
      end

      it "should strip the reset too" do
        expect(subject).to eq "hello"
      end
    end

    context "with multiple colors" do
      subject do
        ansi.strip(ansi.red(ansi.yellow("hello")))
      end

      it "should strip it all" do
        expect(subject).to eq "hello"
      end
    end
  end

  #

  describe "#jump" do
    subject do
      ansi.jump("hello", 1024)
    end

    it "should give ansi to jump up and down" do
      expect(subject).to match %r!\[1024A|\[1024B\Z!
    end
  end
end
