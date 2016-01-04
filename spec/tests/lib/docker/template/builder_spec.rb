# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Builder do
  include_contexts :docker, :repos

  #

  after do |ex|
    unless ex.metadata[:skip_unlink]
      subject.unlink
    end
  end

  #

  subject do
    mocked_repos.to_scratch
  end

  #

  before do |ex|
    mocked_repos.as ex.metadata[:repo_type] || :scratch
    allow(subject).to receive( :build_context).and_return nil
    allow(subject).to receive(:verify_context).and_return nil
  end

  #

  describe "#parent_repo" do
    before do
      mocked_repos.with_init("tag" => "world")
      mocked_repos.with_opts({
        "tags" => {
          "hello" => "world"
        },

        "aliases" => {
          "world" => "hello"
        }
      })
    end

    it "should pull out the aliased repo" do
      expect(mocked_repos.to_normal.parent_repo.tag).to eq "hello"
    end
  end

  #

  describe "#alias?" do
    it "should return false" do
      expect(mocked_repos.to_normal.alias?).to eq false
    end

    context "when a simple alias" do
      before do
        mocked_repos.with_opts({
          "aliases" => { "hello" => "true" },
          "tags" => {
            "default" => "normal"
          }
        })
      end

      it "should return true" do
        expect(mocked_repos.with_init("tag" => "hello") \
          .to_normal.alias?).to eq true
      end
    end

    context "when a complex alias" do
      before do
        mocked_repos.with_opts({
          "aliases" => { "hello" => "default" },
          "tags" => {
            "default" => "normal"
          },

          "env" => {
            "tag" => {
              "hello" => [
                "world"
              ]
            }
          }
        })
      end

      it "should return false" do
        expect(mocked_repos.with_init("tag" => "hello").to_normal \
          .alias?).to eq false
      end
    end
  end

  #

  describe "#push" do
    before do
      subject.repo.metadata.merge({
        "push" => true
      })
    end

    #

    after do
      silence_io { subject.build }
      subject.repo.metadata.merge({
        "push" => false
      })
    end

    #

    it "should try to auth" do
      expect(Docker::Template::Auth).to receive :auth! do
        nil
      end
    end

    #

    context do
      before do
        allow(Docker::Template::Auth).to receive :auth! do
          nil
        end
      end

      #

      it "should try to push" do
        expect(image_mock).to receive(:push) do
          nil
        end
      end
    end

    context "when push == false" do
      before do
        subject.repo.metadata.merge({
          "push" => false
        })
      end

      it "should not try to push the repo" do
        expect(image_mock).not_to receive(:push) do
          nil
        end
      end
    end
  end

  #

  describe "#copy_prebuild_and_verify" do
    after do
      subject.send :copy_prebuild_and_verify
    end

    #

    Docker::Template::Builder::COPY.each do |method|
      it "should message #{method}" do
        expect(subject).to receive(method) do
          nil
        end
      end
    end
  end

  #

  context do
    before do |ex|
      subject.send :setup_context
      allow(subject).to receive( :rootfs?).and_return ex.metadata[ :rootfs]
      allow(subject).to receive(:scratch?).and_return ex.metadata[:scratch]
      allow(subject).to receive( :normal?).and_return ex.metadata[ :normal]
      allow(subject).to receive(:simple_copy?).and_return \
        ex.metadata[:simple_copy]
    end

    #

    describe "#copy_global" do
      after do
        subject.send :copy_global
      end

      #

      [:scratch, :normal].each do |val|
        context "when it's #{val}", val do
          it "should copy" do
            expect(Docker::Template::Utils::Copy).to receive :directory do
              nil
            end
          end
        end
      end
    end

    #

    describe "#simple_copy", :simple do
      after do
        subject.send :simple_copy
      end

      #

      it "should copy", :simple_copy do
        expect(Docker::Template::Utils::Copy).to receive :directory do
          nil
        end
      end

      #

      context "when !simple_copy?" do
        it "should not copy" do
          expect(Docker::Template::Utils::Copy).not_to receive :directory do
            nil
          end
        end
      end
    end

    #

    shared_examples :copy do
      context "when it's scratch", :scratch do
        it "should copy" do
          expect(Docker::Template::Utils::Copy).to receive :directory do
            nil
          end
        end

        #

        context "when simple_copy?", :simple_copy do
          it "should not copy" do
            expect(Docker::Template::Utils::Copy).not_to receive :directory do
              nil
            end
          end
        end
      end

      #

      context "when it's simple", :simple do
        it "should copy" do
          expect(Docker::Template::Utils::Copy).to receive :directory do
            nil
          end
        end

        #

        context "when simple_copy?", :simple_copy do
          it "should not copy" do
            expect(Docker::Template::Utils::Copy).not_to receive :directory do
              nil
            end
          end
        end
      end

      #

      context "when it's a rootfs", :rootfs do
        it "should not copy" do
          expect(Docker::Template::Utils::Copy).not_to receive :directory do
            nil
          end
        end

        #

        context "when simple_copy?", :simple_copy do
          it "should not copy" do
            expect(Docker::Template::Utils::Copy).not_to receive :directory do
              nil
            end
          end
        end
      end
    end

    #

    [:copy_tag, :copy_type, :copy_all].each do |method|
      describe "##{method}" do
        after do
          subject.send method
        end

        # SHARED_EXAMPLES
        it_behaves_like :copy
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

    #

    shared_examples :build do
      it "should build from the context" do
        expect(Docker::Image).to receive :build_from_dir
      end

      #

      it "should tag the image" do
        expect(image_mock).to receive :tag do
          nil
        end
      end

      #

      it "should cleanup", :skip_unlink do
        expect(subject).to receive(:unlink).and_call_original
      end

      #

      it "should not throw any errors" do
        expect { silence_io { subject.build }}.not_to raise_error
      end

      #

      it "should notify of the build", :noisey do
        expect(Docker::Template::Utils).to receive :notify_build do
          nil
        end
      end

      #

      it "should clear the screen" do
        expect(Simple::Ansi).to receive :clear do
          nil
        end
      end
    end

    #

    context "when @subject.type == normal", :repo_type => :normal do
      it_behaves_like :build
    end

    #

    context "when @subject.type == scratch" do
      before do
        allow(subject).to receive(:create_args).and_return({})
        allow(subject).to receive( :start_args).and_return({})
      end

      # SHARED EXAMPLES!
      it_behaves_like :build
    end
  end
end
