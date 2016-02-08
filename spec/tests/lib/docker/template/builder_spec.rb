# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "rspec/helper"
describe Docker::Template::Builder do
  include_contexts :docker, :repos

  #

  after do |ex|
    unless ex.metadata[:skip_teardown]
      subject.teardown
    end
  end

  #

  subject do |ex|
    mocked_repo.send(
      "to_#{ex.metadata[:type]}"
    )
  end

  #

  before do
    # rubocop:disable Style/SpaceInsideParens
    allow(subject).to receive(:verify_context).and_return nil
    allow(subject).to receive( :build_context).and_return nil
    # rubocop:enable Style/SpaceInsideParens
  end

  #

  describe "#alias?" do
    it "should return false" do
      expect(mocked_repo.to_normal.alias?).to eq(
        false
      )
    end

    context "when a simple alias" do
      before do
        mocked_repo.add_alias(
          "hello"
        )
      end

      it "should return true" do
        expect(mocked_repo.with_repo_init("tag" => "hello").to_normal.alias?).to eq(
          true
        )
      end
    end

    context "when a complex alias" do
      before do
        mocked_repo.add_alias "hello"
        mocked_repo.with_opts({
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
        expect(mocked_repo.with_repo_init("tag" => "hello").to_normal.alias?).to eq(
          false
        )
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
      expect(subject).to receive(:auth!).and_return(
        nil
      )
    end

    #

    context do
      before do
        allow(subject).to receive(:auth!).and_return(
          nil
        )
      end

      #

      it "should try to push" do
        expect(image_mock).to receive(:push).and_return(
          nil
        )
      end
    end

    #

    context "when push == false" do
      before do
        subject.repo.metadata.merge({
          "push" => false
        })
      end

      #

      it "should not try to push the repo" do
        expect(image_mock).not_to receive(
          :push
        )
      end
    end
  end

  #

  context do
    before do
      subject.send(
        :setup_context
      )
    end

    #

    describe "#copy_global" do
      context "when it's a scratch image" do
        it "should copy", :type => :scratch do
          expect_any_instance_of(Pathutil).to receive(:safe_copy).and_return(
            nil
          )
        end
      end

      #

      context "when it's a normal image" do
        it "should copy", :type => :normal do
          expect_any_instance_of(Pathutil).to receive(:safe_copy).and_return(
            nil
          )
        end
      end

      #

      context "when it's a rootfs image" do
        it "should not copy", :type => :rootfs do
          expect_any_instance_of(Pathutil).not_to receive(:safe_copy).and_return(
            nil
          )
        end
      end

      #

      after do
        subject.send(
          :copy_global
        )
      end
    end

    #

    describe "#simple_copy" do
      it "should copy", :layout => :simple do
        expect_any_instance_of(Pathutil).to receive(:safe_copy).and_return(
          nil
        )
      end

      #

      context "when !simple_copy?" do
        it "should not copy", :layout => :complex do
          expect_any_instance_of(Pathutil).not_to receive(
            :safe_copy
          )
        end
      end

      #

      after do
        subject.send(
          :simple_copy
        )
      end
    end

    #

    shared_examples :copy do
      context "when it's scratch" do
        it "should copy", :type => :scratch do
          expect_any_instance_of(Pathutil).to receive(:safe_copy).and_return(
            nil
          )
        end

        #

        context "when simple_copy?" do
          it "should not copy", :layout => :simple, :type => :scratch do
            expect_any_instance_of(Pathutil).not_to receive(
              :safe_copy
            )
          end
        end
      end

      #

      context "when it's normal" do
        it "should copy", :type => :normal do
          expect_any_instance_of(Pathutil).to receive(:safe_copy).and_return(
            nil
          )
        end

        #

        context "when simple_copy?" do
          it "should not copy", :type => :normal, :layout => :simple do
            expect_any_instance_of(Pathutil).not_to receive(
              :safe_copy
            )
          end
        end
      end

      #

      context "when it's a rootfs" do
        it "should not copy", :type => :rootfs do
          expect_any_instance_of(Pathutil).not_to receive(
            :safe_copy
          )
        end

        #

        context "when simple_copy?", :simple_copy do
          it "should not copy", :type => :rootfs, :layout => :simple do
            expect_any_instance_of(Pathutil).not_to receive(
              :safe_copy
            )
          end
        end
      end
    end

    #

    describe "#copy_tag" do
      it_behaves_like(
        :copy
      )

      #

      after do
        subject.send(
          :copy_tag
        )
      end
    end

    #

    describe "#copy_group" do
      after do
        subject.send(
          :copy_group
        )
      end

      it_behaves_like(
        :copy
      )
    end

    #

    describe "#copy_all" do
      after do
        subject.send(
          :copy_all
        )
      end

      it_behaves_like(
        :copy
      )
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
      context do
        before do
          allow(subject.repo).to receive(:buildable?).and_return false
          allow(subject).to receive(:build) \
            .and_call_original
        end

        #

        it "should check if the repo is buildable" do
          expect(subject.repo).to receive(:buildable?).and_return(
            nil
          )
        end
      end

      #

      context "when building? is set to false" do
        before do
          allow(subject.repo).to receive(:buildable?).and_return false
          allow(subject).to receive(:build) \
            .and_call_original
        end

        #

        it "should not build" do
          expect(subject).not_to receive(
            :chdir_build
          )
        end
      end

      #

      it "should build from the context" do
        expect(Docker::Image).to receive(
          :build_from_dir
        )
      end

      #

      it "should teardown", :skip_teardown => true do
        expect(subject).to receive(:teardown) \
          .and_call_original
      end

      #

      it "should not throw any errors" do
        expect { silence_io { subject.build }}.not_to(
          raise_error
        )
      end

      #

      it "should notify of the build", :noisey do
        expect(Docker::Template::Utils::Notify).to receive(:build).and_return(
          nil
        )
      end

      #

      it "should clear the screen" do
        expect(Simple::Ansi).to receive(:clear).and_return(
          nil
        )
      end
    end

    #

    context "when @subject.type == normal", :type => :normal do
      it_behaves_like(
        :build
      )
    end

    #

    context "when subject.type == scratch" do
      before do
        # rubocop:disable Style/SpaceInsideParens
        allow(subject).to receive(:create_args).and_return({})
        allow(subject).to receive( :start_args).and_return({})
        # rubocop:enable Style/SpaceInsideParens
      end

      it_behaves_like(
        :build
      )
    end
  end
end
