# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Interface do
  include_context :repos

  #

  before do
    mocked_repos.as :normal
    allow_any_instance_of(Docker::Template::Repo).to receive(:build).and_return nil
    allow(described_class).to receive( :exit).and_return nil
    allow(described_class).to receive(:abort).and_return nil
    allow(described_class).to receive( :exec).and_return nil
  end

  #

  describe "#run" do
    subject do
      described_class.new([
        "default"
      ])
    end

    #

    it "should check if we are only syncing" do
      expect(subject).to receive(:only_sync?)
    end

    #

    after do
      subject.run
    end

    #

    context "when --sync is given" do
      before do
        allow_any_instance_of(Docker::Template::Normal).to receive :sync
        allow_any_instance_of(Docker::Template::  Repo).to receive :syncable? do
          true
        end
      end

      #

      subject do
        described_class.new([
          "--sync",
          "default"
        ])
      end

      #

      it "should defer syncing until the end" do
        expect_any_instance_of(Docker::Template::Repo).to \
          receive(:disable_sync!)
      end

      #

      it "should unlink with syncing disabled since it explicitly syncs" do
        expect_any_instance_of(Docker::Template::Normal).to \
        receive(:unlink).with({
          sync: false
        })
      end

      #

      it "should check if the repo is even syncable" do
        expect_any_instance_of(Docker::Template::Repo).to receive :syncable?
      end

      #

      context "when the repo is not syncable" do
        before do
          klass = Docker::Template::Repo
          allow_any_instance_of(klass).to receive :syncable? do
            false
          end
        end

        #

        specify do
          klass = Docker::Template::Normal
          expect_any_instance_of(klass).not_to receive :sync
        end
      end
    end

    #

    context "when --sync is not given" do
      it "should not sync" do
        klass = Docker::Template::Normal
        expect_any_instance_of(klass).not_to receive :sync
      end
    end
  end

  #

  describe ".bin?" do
    it "should return true if 0 is Docker" do
      expect(described_class.bin?("docker")).to eq true
    end

    #

    context "with a bad value" do
      it "should not throw; return false" do
        expect(described_class.bin?(nil)).to eq false
      end
    end
  end

  #

  describe ".discover" do
    let :tmpbin do
      Dir.mktmpdir("bin")
    end

    #

    before do
      file = File.join(tmpbin, "docker")
      ENV["PATH"] = "#{tmpbin}:#{ENV["PATH"]}"
      FileUtils.touch file
      FileUtils.chmod("u+rx", \
        file)
    end

    #

    it "should find the Docker binary" do
      expect(described_class.discover).to match %r!\/docker\Z!
    end

    #

    after do
      FileUtils.rm_rf(tmpbin)
    end

    #

    context "with a bad path" do
      before do
        ENV["PATH"] = "/hello/world/bin:#{ENV["PATH"]}"
      end

      #

      it "should not raise an error" do
        expect { described_class.discover }.not_to \
          raise_error
      end
    end
  end

  describe ".start" do
    before :all do
      module Mocks
        class Interface
          def run
            #
          end
        end
      end
    end

    #

    after :all do
      Mocks.send(:remove_const, :Interface)
    end

    #

    before do
      stub_const("ARGV", %W(hello world))
      allow(Docker::Template::Interface).to receive(:new) do
        Mocks::Interface.new
      end
    end

    #

    context "when called as docker" do
      before do
        allow(described_class).to receive(:abort) do
          nil
        end
      end

      #

      it "should msg discover" do
        expect(described_class).to receive(:discover)
      end

      #

      after do
        described_class.start("docker")
      end

      #

      context "when it cannot find a bin" do
        before do
          allow(described_class).to receive(:discover) do
            nil
          end
        end

        #

        it "should abort" do
          expect(described_class).to receive(:abort)
        end
      end
    end

    #

    context "when an error occurs" do
      before do
        allow(described_class).to receive(:new) do
          raise Docker::Template::Error::NotImplemented
        end
      end

      #

      it "should log the error" do
        result = capture_io { described_class.start("docker-template") }
        expect(result[:stderr]).not_to be_empty
      end
    end
  end
end
