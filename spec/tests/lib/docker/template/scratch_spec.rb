# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "rspec/helper"
describe Docker::Template::Scratch do
  include_contexts :docker, :repos

  #

  before do
    mocked_repo.init({
      :type => :normal
    })
  end

  #

  subject do
    mocked_repo.with_repo_init("tag" => "latest")
    mocked_repo.to_scratch
  end

  #

  before do
    allow(subject).to receive(:create_args).and_return({})
    allow(subject).to receive(:verify_context).and_return nil
    allow(subject).to receive(:start_args).and_return({})
  end

  #

  describe "#data" do
    before do
      subject.send(
        :setup_context
      )
    end

    #

    it "adds the TARGZ file" do
      expect(subject.data).to match(
        %r!^ADD .*\.tar\.gz /$!m
      )
    end

    #

    it "adds the MAINTAINER" do
      expect(subject.data).to match %r!MAINTAINER #{Regexp.escape(
        subject.repo.metadata["maintainer"]
      )}!
    end

    #

    it "should not return empty data" do
      expect(subject.data).not_to(
        be_empty
      )
    end

    #

    after do
      subject.teardown
    end
  end

  #

  describe "#setup_context" do
    before do
      subject.send(
        :setup_context
      )
    end

    #

    it "should copy the Dockerfile" do
      expect(subject.instance_variable_get(:@context).find.map(&:to_s)).to include match(
        /\/Dockerfile\Z/
      )
    end

    #

    after do
      subject.teardown
    end
  end

  #

  describe "#teardown" do
    before do
      silence_io do
        subject.build
      end
    end

    #

    context "(img: true)" do
      it "should delete the image" do
        expect(image_mock).to receive(
          :delete
        )
      end

      #

      after do
        subject.teardown({
          :img => true
        })
      end
    end

    #

    context do
      let :pathname do
        subject.instance_variable_get(
          :@context
        )
      end

      #

      before do
        subject.teardown
      end

      #

      it "should remove the context" do
        expect(pathname).not_to(
          exist
        )
      end
    end
  end

  #

  describe "#build_context" do
    before do
      allow_any_instance_of(Docker::Template::Rootfs).to receive(:build).and_return(
        nil
      )
    end

    after do |ex|
      unless ex.metadata[:nobuild]
        subject.send(
          :build_context
        )
      end
    end

    #

    it "should build the rootfs context" do
      expect(subject.rootfs).to receive(
        :build
      )
    end

    #

    it "should stop the rootfs container once it's done" do
      expect(container_mock).to receive(
        :stop
      )
    end

    #

    it "should teardown the rootfs image" do
      expect(subject.rootfs).to receive(
        :teardown
      )
    end

    #

    it "should delete the rootfs container" do
      expect(container_mock).to receive(
        :delete
      )
    end

    #

    context "when an image exists badly" do
      before do
        allow(container_mock).to receive :json do
          {
            "State" => {
              "ExitCode" => 1
            }
          }
        end
      end

      #

      it "should raise an error", :nobuild do
        expect { subject.send :build_context }.to raise_error(
          Docker::Template::Error::BadExitStatus
        )
      end
    end
  end
end
