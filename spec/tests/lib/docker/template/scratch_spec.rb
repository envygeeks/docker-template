# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Scratch do
  include_context :docker_mocks

  subject do
    scratch.new(repo)
  end

  let :repo do
    Docker::Template::Repo.new({
      "repo" => "scratch",
       "tag" =>  "latest"
    })
  end

  let :scratch do
    described_class
  end

  before do
    allow_any_instance_of(scratch).to receive(:verify_context).and_return nil
    allow_any_instance_of(scratch).to receive(:create_args).and_return({})
    allow_any_instance_of(scratch).to receive( :start_args).and_return({})
  end

  #

  describe "#data" do
    after do
      instance.unlink
    end

    subject do
      instance.data
    end

    let :instance do
      scratch.new(repo).tap do |obj|
        obj.send :setup_context
      end
    end

    it "adds the TARGZ file" do
      expect(subject).to match %r!^ADD .*\.tar\.gz /$!m
    end

    it "adds the MAINTAINER" do
      expect(subject).to match %r!MAINTAINER #{
        Regexp.escape(repo.metadata["maintainer"])
      }!
    end

    it "should not return empty data" do
      expect(subject).not_to \
        be_empty
    end
  end

  #

  describe "#setup_context" do
    after do
      instance.unlink
    end

    subject do
      instance.instance_variable_get(:@context).children.map do |val|
        val.to_path
      end
    end

    let :instance do
      scratch.new(repo)
    end

    before do
      instance.send :setup_context
    end

    it "should copy the Dockerfile" do
      expect(subject).to include match(/\/Dockerfile\Z/)
    end
  end

  #

  describe "#unlink" do
    before do
      silence_io do
        subject.build
      end
    end

    context "(img: true)" do
      after do
        subject.unlink(img: true)
      end

      it "should delete the image" do
        expect(docker_image_mock).to \
          receive(:delete)
      end
    end

    context do
      let :pathname do
        subject.instance_variable_get(:@context)
      end

      before do
        subject.unlink
      end

      it "should remove the context" do
        expect(pathname).not_to \
          exist
      end
    end
  end

  #

  describe "#build_context" do
    after do |ex|
      unless ex.metadata[:nobuild]
        subject.send :build_context
      end
    end

    it "should stop the rootfs container once it's done" do
      expect(docker_container_mock).to \
        receive :stop
    end

    it "should delete the rootfs container" do
      expect(docker_container_mock).to \
        receive :delete
    end

    context "when nothing logged" do
      before do
        allow(docker_container_mock).to \
          receive :attach
      end

      it "should pull the logs out of the stream" do
        expect(docker_container_mock).to \
          receive(:streaming_logs)
      end
    end

    context "when an image exists badly" do
      before do
        allow(docker_container_mock).to receive :json do
          {
            "State" => {
              "ExitCode" => 1
            }
          }
        end
      end

      it "should raise an error", :nobuild do
        expect_it = expect do
          subject.send :build_context
        end

        expect_it.to raise_error \
          Docker::Template::Error::BadExitStatus
      end
    end
  end
end
