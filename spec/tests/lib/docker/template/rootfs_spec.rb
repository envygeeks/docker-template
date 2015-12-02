# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
RSpec.describe Docker::Template::Rootfs do
  include_context :docker_mocks

  let(:rootfs) { described_class }
  let(:repo) { in_data { Docker::Template::Repo.new("repo" => "scratch", "tag" => "latest") }}
  subject { rootfs.new(repo) }

  describe "#data" do
    subject { rootfs.new(repo).data }
    it { is_expected.to match %r!\AFROM [a-z]+/ubuntu:tiny! }
    it { is_expected.not_to be_empty }
  end

  describe "#build" do
    after do |ex|
      unless ex.metadata[:skip_build]
        ex.metadata[:noisy] ? subject.build : silence_io do
          subject.build
        end
      end
    end

    specify { expect(Docker::Template::Ansi).to receive :clear }
    specify(nil, :noisy => true) { expect(Docker::Template::Util).to receive :notify_build }
    specify(nil, :skip_build => true) { expect { silence_io { subject.build }}.not_to raise_error }
    specify { is_expected.to receive(:unlink).and_call_original }
    specify { expect(Docker::Image).to receive :build_from_dir }
    specify { expect(docker_image_mock).to receive :tag }
  end

  describe "#unlink" do
    specify { expect(subject.instance_variable_get(:@context)).to_not exist }
    before { silence_io { subject.build }}

    context "(img: true)" do
      context do
        specify { expect(docker_image_mock).to receive(:delete) }
        after { subject.unlink(img: true) }
      end

      context "when metadata['keep_rootfs'] = true" do
        before { user_metadata["keep_rootfs"] = true }
        let(:user_metadata) { subject.instance_variable_get(:@repo).metadata.instance_variable_get(:@metadata) }
        specify { expect(docker_image_mock).not_to receive :delete }
        after { user_metadata["keep_rootfs"] = false }
        after { subject.unlink }
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

    specify { expect(&subject).to raise_error Docker::Template::Error::NoRootfsMkimg }
  end

  context "when no copy directory exists" do
    subject do
      -> do
        silence_io do
          in_data do
            rootfs.new(Docker::Template::Repo.new({
              "repo" =>   "bad2",
               "tag" => "latest"
            })).build
          end
        end
      end
    end

    specify { expect(&subject).to raise_error Docker::Template::Error::NoRootfsCopyDir }
  end
end
