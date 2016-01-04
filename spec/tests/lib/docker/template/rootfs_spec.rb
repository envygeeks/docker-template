# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
RSpec.describe Docker::Template::Rootfs do
  include_contexts :docker, :repos

  #

  subject do
    mocked_repos.with_init("tag" => "default")
    mocked_repos.to_rootfs
  end

  #

  before do
    mocked_repos.as :scratch
  end

  #

  describe "#data" do
    it "should add the FROM line" do
      expect(subject.data).to match %r!\AFROM [a-z]+/ubuntu!
    end
  end

  #

  describe "#copy_rootfs" do
    after do
      subject.send :copy_rootfs
    end

    #

    it "should copy" do
      expect(Docker::Template::Utils::Copy).to receive :directory do
        nil
      end
    end

    #

    context "when simple_copy?" do
      before do
        allow(subject).to receive(:simple_copy?) do
          true
        end
      end

      #

      it "should do a simple copy" do
        expect(subject).to receive :simple_rootfs_copy do
          nil
        end
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
      expect(subject.instance_variable_get(:@context)).not_to exist
    end

    #

    context "(img: true)" do
      context do
        it "should delete the image" do
          expect(image_mock).to receive :delete do
            nil
          end
        end

        #

        after do
          subject.unlink(img: true)
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
          expect(image_mock).not_to receive :delete do
            nil
          end
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

  context "when no mkimg exists" do
    before do
      mocked_repos.delete("copy/rootfs")
    end

    #

    it "should raise an error" do
      expect { silence_io { subject.build }}.to raise_error \
        Docker::Template::Error::NoRootfsMkimg
    end
  end
end
