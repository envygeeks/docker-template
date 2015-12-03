# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Ansi do
  let(:ansi) { described_class }
  describe "#clear" do
    subject { capture_io { ansi.clear }}
    specify("", :clear => true) { expect(ansi.has?(subject[:stdout])).to eq true }
  end

  Docker::Template::Ansi::COLORS.keys.map do |color|
    it { is_expected.to respond_to color }
  end

  describe "#clear_line" do
    subject { ansi.clear_line("hello") }
    specify { expect(ansi.has?(subject)).to eq true }
  end

  describe "#has?" do
    subject { ansi.has?(ansi.blue("hello")) }
    it { is_expected.to eq true }
  end

  describe "#strip" do
    subject { ansi.strip(ansi.red("hello")) }
    it { is_expected.to eq "hello" }

    context "with reset" do
      subject { ansi.strip(ansi.red(ansi.reset("hello"))) }
      it { is_expected.to eq "hello" }
    end

    context "with multiple colors" do
      subject { ansi.strip(ansi.red(ansi.yellow("hello"))) }
      it { is_expected.to eq "hello" }
    end
  end

  describe "#jump" do
    describe "(up: \\d)" do
      subject { ansi.jump("hello", up: 1024) }
      it { is_expected.to match %r!\[1024A! }
    end

    context "(down: \\d)" do
      subject { ansi.jump("hello", down: 1024) }
      it { is_expected.to match %r!\[1024B! }
    end

    context "(both: \\d)" do
      subject { ansi.jump("hello", both: 1024) }
      it { is_expected.to match %r!\[1024A|\[1024B\Z! }
    end
  end
end
