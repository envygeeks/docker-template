# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "rspec/helper"
RSpec.describe Docker::Template::Rootfs do
  include_contexts :docker, :repos

  #

  subject do
    mocked_repo.to_rootfs
  end

  #

  before do
    mocked_repo.with_repo_init({
      "tag" => "default"
    })
  end

  #

  describe "#data" do
    it "should add the FROM line" do
      expect(subject.data).to match(
        %r!\AFROM [a-z]+/ubuntu!
      )
    end
  end

  #

  describe "#copy_rootfs" do
    before do
      subject.send(
        :setup_context
      )
    end

    after do
      subject.send(
        :copy_rootfs
      )
    end

    #

    it "should copy", :type => :rootfs, :layout => :complex do
      expect_any_instance_of(Pathutil).to receive(:safe_copy).and_return(
        nil
      )
    end

    #

    context "when simple_copy?" do
      before do
        allow(subject).to receive(:simple_copy?).and_return(
          true
        )
      end

      #

      it "should do a simple copy" do
        expect(subject).to receive(:simple_rootfs_copy).and_return(
          nil
        )
      end
    end
  end

  #

  describe "#unlink" do
    before do
      silence_io do
        subject.build
      end
    end

    #

    it "should delete the context it created" do
      expect(subject.instance_variable_get(:@context)).not_to(
        exist
      )
    end

    #

    context "(img: true)" do
      context do
        it "should delete the image" do
          expect(image_mock).to receive(:delete).and_return(
            nil
          )
        end

        #

        after do
          subject.unlink({
            :img => true
          })
        end
      end

      #

      context "when metadata['keep_rootfs'] = true" do
        before do
          user_metadata.merge({
            "keep_rootfs" => true
          })
        end

        #

        let :user_metadata do
          subject.instance_variable_get(:@repo).metadata
        end

        #

        it "should not delete the rootfs img" do
          expect(image_mock).not_to receive(
            :delete
          )
        end

        #

        after do
          subject.unlink
          user_metadata.merge({
            "keep_rootfs" => false
          })
        end
      end
    end
  end

  #

  context "when no mkimg exists", :layout => :simple, :type => :scratch do
    before do
      mocked_repo.delete(
        "copy/usr/local/bin/mkimg"
      )
    end

    #

    it "should raise an error" do
      expect { silence_io { subject.build }}.to raise_error(
        Docker::Template::Error::NoRootfsMkimg
      )
    end
  end
end
