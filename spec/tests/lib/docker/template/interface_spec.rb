# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Interface do
  include_context :repos

  #

  before do
    allow_any_instance_of(Docker::Template::Repo).to receive(:build).and_return nil
    allow(described_class).to receive( :exit).and_return nil
    allow(described_class).to receive(:abort).and_return nil
    allow(described_class).to receive( :exec).and_return nil
    mocked_repo.init :type => :normal
  end

  #

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
        expect(Docker::Template::Utils::System).to receive(:docker_bin)
      end

      #

      after do
        described_class.start("docker")
      end

      #

      context "when it cannot find a bin" do
        before do
          allow(Docker::Template::Utils::System).to receive(:docker_bin) do
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
