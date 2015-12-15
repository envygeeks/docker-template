# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
RSpec.describe Docker::Template::Rootfs do
  include_context :docker_mocks

  let :rootfs do
    described_class
  end

  let :repo do
    in_data do
      Docker::Template::Repo.new({
        "repo" => "scratch",
        "tag"  =>  "latest",
      })
    end
  end

  subject do
    rootfs.new(repo)
  end

  describe "#data" do
    subject do
      rootfs.new(repo).data
    end

    it "should add the FROM line" do
      expect(subject).to match %r!\AFROM [a-z]+/ubuntu!
    end
  end

  describe "#copy_rootfs" do
    after do
      subject.send :copy_rootfs
    end

    it "should copy" do
      expect(Docker::Template::Util::Copy).to receive :directory do
        nil
      end
    end

    context "when simple_copy?" do
      before do
        allow(subject).to receive(:simple_copy?) do
          true
        end
      end


      it "should do a simple copy" do
        expect(subject).to receive :simple_rootfs_copy do
          nil
        end
      end
    end
  end

  describe "#unlink" do
    before do
      silence_io do
        subject.build
      end
    end

    it "should delete the context it created" do
      expect(subject.instance_variable_get(:@context)).not_to exist
    end

    context "(img: true)" do
      context do
        it "should delete the image" do
          expect(docker_image_mock).to receive :delete do
            nil
          end
        end

        after do
          subject.unlink(img: true)
        end
      end

      context "when metadata['keep_rootfs'] = true" do
        before do
          user_metadata["keep_rootfs"] = true
        end

        let :user_metadata do
          subject.instance_variable_get(:@repo).metadata. \
            instance_variable_get(:@metadata)
        end

        it "should not delete the rootfs img" do
          expect(docker_image_mock).not_to receive :delete do
            nil
          end
        end

        after do
          subject.unlink
          user_metadata["keep_rootfs"] = \
            false
        end
      end
    end
  end

  context "when no mkimg exists" do
    subject do
      -> do
        silence_io do
          in_data do
            rootfs.new(Docker::Template::Repo.new({
              "repo" =>   "bad1",
               "tag" => "latest"
            })).build
          end
        end
      end
    end

    it "should raise an error" do
      expect(&subject).to raise_error Docker::Template::Error::NoRootfsMkimg
    end
  end
end
