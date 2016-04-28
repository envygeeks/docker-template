# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "rspec/helper"
describe Docker::Template::Builder::Normal, :type => :normal do
  include_contexts :docker, :repos

  #

  subject do
    mocked_repo.with_repo_init("tag" => "latest")
    mocked_repo.to_normal
  end

  #

  it "should allow projects" do
    expect(described_class.projects_allowed?).to eq(
      true
    )
  end

  #

  it "should allow what Dockerfiles it allows" do
    expect(described_class.files).not_to(
      be_empty
    )
  end

  #

  describe "#copy_dockerfile" do
    context "when the it's a project build", :type => :project do
      it "should pull the Dockerfile from the root" do
        expect(Docker::Template).to receive(:root) \
          .and_call_original
      end
    end

    #

    it "should pull the Dockerfile from the repo root" do
      expect(subject.repo).to receive(:root) \
        .and_call_original
    end

    #

    it "should create an ERB context" do
      expect(ERB::Context).to receive(:new) \
        .and_call_original
    end

    #

    after do
      subject.send(:setup_context)
      subject.teardown
    end
  end

  #

  describe "#cache_context" do
    context "when cache = false" do
      before do
        subject.repo.meta.merge!({
          "cache" => false
        })
      end

      #

      context do
        before do
          silence_io do
            subject.send(
              :cache_context
            )
          end
        end

        #

        it "should not copy all the files" do
          expect(subject.repo.cache_dir).not_to(
            exist
          )
        end
      end

      #

      context do
        it "should not call cache to copy it" do
          expect(Docker::Template::Cache).not_to receive(
            :context
          )
        end

        #

        after do
          subject.send(
            :cache_context
          )
        end
      end
    end

    #

    context "when cache = true" do
      before do
        subject.repo.meta.merge!({
          "cache" => true
        })
      end

      #

      context do
        before do
          silence_io do
            subject.send :setup_context
            subject.send :cache_context
          end
        end

        #

        it "should copy all the files" do
          expect(subject.repo.cache_dir).to(
            exist
          )
        end
      end

      #

      context do
        it "should call the cache to copy it" do
          expect(Docker::Template::Cache).to receive(:context).and_return(
            nil
          )
        end

        #

        after do
          subject.send(
            :cache_context
          )
        end
      end

      #

      after do
        subject.teardown
        subject.repo.meta.merge!({
          "cache" => false
        })
      end
    end
  end

  #

  describe "#teardown" do
    before do
      subject.send :setup_context
      subject.teardown
    end

    #

    it "should delete the context folder" do
      expect(subject.instance_variable_get(:@context)).not_to(
        exist
      )
    end

    #

    context "(img: true)" do
      before do
        subject.instance_variable_set(
          :@img, image_mock
        )
      end

      #

      it "should try to delete the image" do
        expect(image_mock).to receive(
          :delete
        )
      end

      #

      after do
        subject.teardown(img: true)
        subject.remove_instance_variable(:@img)
      end
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
        /Dockerfile\Z/
      )
    end

    #

    after do
      subject.teardown
    end
  end
end
