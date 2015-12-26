# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Normal do
  include_contexts :docker, :repos

  #

  subject do
    mocked_repos.with_init("tag" => "latest")
    mocked_repos.to_normal
  end

  #

  before do
    mocked_repos.as :normal
  end

  #

  describe "#unlink" do
    before do
      subject.send :setup_context
      subject.unlink
    end

    #

    it "should delete the context folder" do
      expect(subject.instance_variable_get(:@context)) \
        .not_to exist
    end

    #

    context "when dockerhub_cache = true" do
      let :user_metadata do
        subject.repo.metadata.instance_variable_get(:@metadata)
      end

      #

      before do
        user_metadata["dockerhub_cache"] = true
      end

      #

      it "should copy the context for Dockerhub" do
        expect(Docker::Template::Util).to receive \
          :create_dockerhub_context
      end

      #

      after do
        subject.unlink # Needs to be before!!!
        user_metadata["dockerhub_cache"] = false
      end
    end

    #

    context "(img: true)" do
      before do
        subject.instance_variable_set(:@img, image_mock)
      end

      #

      it "should try to delete the image" do
        expect(image_mock).to receive \
          :delete
      end

      #

      after do
        subject.unlink(img: true)
        subject.remove_instance_variable(:@img)
      end
    end
  end

  #

  describe "#setup_context" do
    before do
      subject.send :setup_context
    end

    #

    it "should copy the Dockerfile" do
      expect(subject.instance_variable_get(:@context).all_children.map(&:to_s)).to \
        include match(/Dockerfile\Z/)
    end

    #

    after do
      subject.unlink
    end
  end
end
