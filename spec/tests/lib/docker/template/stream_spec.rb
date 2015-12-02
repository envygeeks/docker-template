# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Stream do
  let(:ansi) { Docker::Template::Ansi }
  let(:stream) { described_class }

  def log(type, what)
    io = capture_io { stream.new.log(what.to_json) }
    type == :both ? io : io[type]
  end

  describe "#progress_log" do
    subject { log :stdout, "progress" => "world", "id" => "hello" }
    specify { expect(ansi.strip(subject).gsub(/\r/, "")).to eq "hello: world" }
    specify { expect(ansi.has?(subject)).to eq true }

    context "when no ID is present" do
      subject { log :stdout, "progress" => "world" }
      it { is_expected.to be_empty }
    end

  end

  describe "#log" do
    subject { log :stdout, "stream" => "hello\nworld" }
    it { is_expected.to eq "hello\nworld\n" }

    context "when a message is not handled" do
      subject { log :both, "unknown" => "hello" }
      specify { expect(ansi.has?(subject[:stderr])).to eq true }
      specify { expect(subject[:stdout].strip).to eq({ "unknown" => "hello" }.to_json) }
      specify { expect(subject[:stderr]).not_to be_empty }
    end
  end
end
