# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Common do
  include_context :docker_mocks

  after do
    scratch.unlink
  end

  let :scratch do
    Docker::Template::Scratch.new(Docker::Template::Repo.new({
      "repo" => "scratch"
    }))
  end

  before do
    allow(scratch).to receive( :build_context).and_return nil
    allow(scratch).to receive(:verify_context).and_return nil
  end

  #

  describe "#push" do
    before do
      allow(Docker::Template::Interface).to receive :push? do
        true
      end
    end

    after do
      silence_io do
        scratch.build
      end
    end

    it "should try to auth" do
      expect(Docker::Template::Auth).to receive :auth! do
        nil
      end
    end

    context do
      before { allow(Docker::Template::Auth).to receive(:auth!).and_return nil }
      it "should try to push" do
        expect(docker_image_mock).to receive(:push) do
          nil
        end
      end
    end
  end

  #

  describe "#copy_build_and_verify" do
    after { scratch.send :copy_build_and_verify }
    Docker::Template::Common::COPY.each do |method|
      it "should message #{method}" do
        expect(scratch).to receive(method) do
          nil
        end
      end
    end
  end

  #

  describe "#build" do
    after do |ex|
      unless ex.metadata[:skip]
        ex.metadata[:noisey] ? subject.build : silence_io do
          subject.build
        end
      end
    end

    shared_examples :shared_build_examples do
      it "should build from the context" do
        expect(Docker::Image).to receive \
          :build_from_dir
      end

      it "should tag the image" do
        expect(docker_image_mock).to receive :tag do
          nil
        end
      end

      it "should cleanup" do
        expect(subject).to receive(:unlink) \
          .and_call_original
      end

      it "should not throw any errors" do
        expect_it = expect do
          silence_io do
            subject.build
          end
        end

        expect_it.not_to raise_error
      end

      it "should notify of the build", :noisey do
        expect(Docker::Template::Util).to receive :notify_build do
          nil
        end
      end

      it "should clear the screen" do
        expect(Docker::Template::Ansi).to receive :clear do
          nil
        end
      end
    end

    #

    context "when the type is simple" do
      it_behaves_like :shared_build_examples

      subject do
        Docker::Template::Simple.new(repo)
      end

      let :repo do
        Docker::Template::Repo.new({
          "repo" => "simple",
          "tag"  => "latest"
        })
      end
    end

    #

    context "when @repo.type == scratch" do
      it_behaves_like :shared_build_examples

      before do
        allow(subject).to receive(:verify_context).and_return nil
        allow(subject).to receive(:create_args).and_return({})
        allow(subject).to receive( :start_args).and_return({})
      end

      let :repo do
        Docker::Template::Repo.new({
          "repo" => "scratch",
           "tag" =>  "latest"
        })
      end

      subject do
        Docker::Template::Scratch.new(repo)
      end
    end
  end
end
