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

  describe "#cache_context" do
    context "when dockerhub_cache = false" do
      before do
        subject.repo.metadata.merge({
          "dockerhub_cache" => false
        })
      end

      #

      context do
        before do
          silence_io do
            subject.send :cache_context
          end
        end

        #

        it "should not copy all the files" do
          expect(subject.repo.root.join("cache")).not_to exist
        end
      end

      #

      context do
        it "should not call util to copy it" do
          expect(Docker::Template::Util).not_to receive \
            :create_dockerhub_context
        end

        #

        after do
          subject.send :cache_context
        end
      end
    end

    #

    context "when dockerhub_cache = true" do
      before do
        subject.repo.metadata.merge({
          "dockerhub_cache" => true
        })
      end

      #

      context do
        before do
          silence_io do
            subject.send :cache_context
          end
        end

        #

        it "should copy all the files" do
          expect(subject.repo.root.join("cache")).to exist
        end
      end

      #

      context do
        it "call the util to copy it" do
          expect(Docker::Template::Util).to receive \
            :create_dockerhub_context
        end

        after do
          subject.send :cache_context
        end
      end

      #

      after do
        subject.unlink
        subject.repo.metadata.merge({
          "dockerhub_cache" => false
        })
      end
    end
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
