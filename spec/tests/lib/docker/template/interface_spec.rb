# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Interface do
  let(:interface) { described_class }
  subject { interface }

  before do
    allow_any_instance_of(Docker::Template::Repo).to receive(:build).and_return nil
    allow(interface).to receive(:abort).and_return nil
    allow(interface).to receive( :exit).and_return nil
    allow(interface).to receive( :exec).and_return nil
  end

  describe "#run" do
    after { subject.run }
    subject { interface.new(["simple"]) }
    it { is_expected.to receive(:only_sync?) }
    let(:simple) { Docker::Template::Simple }
    before { allow_any_instance_of(Docker::Template::Parser).to receive(:parse).and_return( \
        Docker::Template::Parser.new(["simple"]).parse)}

    context "when --sync is given" do
      before do
        allow_any_instance_of(simple).to receive(:sync)
        allow_any_instance_of(repo).to receive(:syncable?).and_return(true)
      end

      subject { interface.new(["--sync", "simple"]) }
      specify { expect_any_instance_of(repo).to receive(:disable_sync!) }
      specify { expect_any_instance_of(simple).to receive(:unlink).with(sync: false) }
      specify { expect_any_instance_of(repo).to receive(:syncable?) }
      let(:repo) { Docker::Template::Repo }

      context "when the repo is not syncable" do
        before { allow_any_instance_of(repo).to receive(:syncable?).and_return(false) }
        specify { expect_any_instance_of(simple).not_to receive(:sync) }
      end
    end

    context "when --sync is not given" do
      specify { expect_any_instance_of(simple).not_to receive(  :sync) }
      specify { expect_any_instance_of(simple).not_to receive(:unlink) }
    end
  end

  describe ".bin?" do
    subject { interface.bin?("docker") }
    it { is_expected.to eq true }

    context "with a bad value" do
      subject { interface.bin?(nil) }
      it { is_expected.to eq false }
    end
  end

  describe ".discover" do
    let(:tmpbin) { Dir.mktmpdir("bin") }
    it { is_expected.to match %r!\/docker\Z! }
    after { FileUtils.rm_rf(tmpbin) rescue nil }
    subject { interface.discover }

    before do
      ENV["PATH"] = "#{tmpbin}:#{ENV["PATH"]}"
      FileUtils.touch file = File.join(tmpbin, "docker")
      FileUtils.chmod("u+rx", file)
    end

    context "with a bad path" do
      subject { -> { interface.discover }}
      before { ENV["PATH"] = "/hello/world/bin:#{ENV["PATH"]}" }
      specify { expect(&subject).not_to raise_error }
    end
  end

  describe ".start" do
    before :all do
      class InterfaceMockObject
        def run
          #
        end
      end
    end

    let(:interface_mock_object)  {  InterfaceMockObject.new  }
    after(:all) { Object.send(:remove_const, :InterfaceMockObject) }

    before do
      stub_const("ARGV", %W(hello world))
      allow(interface).to receive(:new).and_return(interface_mock_object)
    end

    context "when called as docker" do
      before { allow(subject).to receive(:abort) }
      specify { allow(subject).to receive(:discovert) }
      after { subject.start("docker") }

      context "when it cannot find a bin" do
        before {   allow(subject).to receive(:discover).and_return nil }
        specify { expect(subject).to receive(:abort) }
      end
    end

    context "when an error occurs" do
      subject { capture_io { interface.start("docker-template") }}
      before { allow(interface).to receive(:new) { raise Docker::Template::Error::NotImplemented }}
      specify { expect(subject[:stderr]).not_to be_empty }
    end
  end
end
