# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Common do
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

  describe "#push" do
    before do
      allow(Docker::Template::Interface).to receive :push? do
        true
      end
    end

    #

    after do
      silence_io do
        subject.build
      end
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
  end

  #

  describe "#copy_build_and_verify" do
    after do
      subject.send :copy_build_and_verify
    end

    #

    Docker::Template::Common::COPY.each do |method|
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
      allow(subject).to receive( :simple?).and_return ex.metadata[ :simple]
      allow(subject).to receive(:simple_copy?).and_return \
        ex.metadata[:simple_copy]
    end

    #

    describe "#copy_global" do
      after do
        subject.send :copy_global
      end

      #

      [:scratch, :simple].each do |val|
        context "when it's #{val}", val do
          it "should copy" do
            expect(Docker::Template::Util::Copy).to receive :directory do
              nil
            end
          end
        end
      end
    end

    #

    describe "#copy_simple", :simple do
      after do
        subject.send :copy_simple
      end

      #

      it "should copy", :simple_copy do
        expect(Docker::Template::Util::Copy).to receive :directory do
          nil
        end
      end

      #

      context "when !simple_copy?" do
        it "should not copy" do
          expect(Docker::Template::Util::Copy).not_to receive :directory do
            nil
          end
        end
      end
    end

    #

    shared_examples :copy do
      context "when it's scratch", :scratch do
        it "should copy" do
          expect(Docker::Template::Util::Copy).to receive :directory do
            nil
          end
        end

        #

        context "when simple_copy?", :simple_copy do
          it "should not copy" do
            expect(Docker::Template::Util::Copy).not_to receive :directory do
              nil
            end
          end
        end
      end

      #

      context "when it's simple", :simple do
        it "should copy" do
          expect(Docker::Template::Util::Copy).to receive :directory do
            nil
          end
        end

        #

        context "when simple_copy?", :simple_copy do
          it "should not copy" do
            expect(Docker::Template::Util::Copy).not_to receive :directory do
              nil
            end
          end
        end
      end

      #

      context "when it's a rootfs", :rootfs do
        it "should not copy" do
          expect(Docker::Template::Util::Copy).not_to receive :directory do
            nil
          end
        end

        #

        context "when simple_copy?", :simple_copy do
          it "should not copy" do
            expect(Docker::Template::Util::Copy).not_to receive :directory do
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
        expect(Docker::Template::Util).to receive :notify_build do
          nil
        end
      end

      #

      it "should clear the screen" do
        expect(Docker::Template::Ansi).to receive :clear do
          nil
        end
      end
    end

    #

    context "when @subject.type == simple", :repo_type => :normal do
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
