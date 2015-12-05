# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Common do
  include_context :docker_mocks
  after { scratch.unlink }

  let :scratch do
    Docker::Template::Scratch.new(Docker::Template::Repo.new({
      "repo" => "scratch"
    }))
  end

  before do
    allow(scratch).to receive( :build_context).and_return(nil)
    allow(scratch).to receive(:verify_context).and_return(nil)
  end

  describe "#push" do
    specify { expect(scratch).to receive(:push) }
    specify { allow(Docker::Template::Auth).to receive(:auth!).and_return nil }
    before { allow(Docker::Template::Interface).to receive(:push?).and_return true }
    specify { expect(Docker::Template::Auth).to receive(:auth!) }
    after { silence_io { scratch.build }}
  end

  describe "#copy_build_and_verify" do
    before { scratch.send(:copy_build_and_verify) }
    subject { scratch.instance_variable_get(:@copy).all_children.map(&:to_path) }
    it { is_expected.to include match %r!\/hello\Z! }
  end

  describe "#build" do
    context "when the type is simple" do
      after do |ex|
        unless ex.metadata[:skip_build]
          ex.metadata[:noisy] ? subject.build : silence_io do
            subject.build
          end
        end
      end

      subject { Docker::Template::Simple.new(repo) }
      specify { expect(Docker::Image).to receive :build_from_dir }
      let(:repo) { in_data { Docker::Template::Repo.new("repo" => "simple", "tag" => "latest")}}
      specify(nil, :skip_build => true) { expect { silence_io { subject.build }}.to_not raise_error }
      specify(nil, :noisy => true) { expect(Docker::Template::Util).to receive(:notify_build) }
      specify { expect(Docker::Template::Ansi).to receive :clear }
      it { is_expected.to receive(:unlink).and_call_original }
      specify { expect(docker_image_mock).to receive :tag }
    end

    context "when the type is scratch" do
      after do |ex|
        unless ex.metadata[:skip_build]
          ex.metadata[:noisy] ? subject.build : silence_io do
            subject.build
          end
        end
      end

      before do
        allow(subject).to receive(:verify_context).and_return nil
        allow(subject).to receive(:create_args).and_return({})
        allow(subject).to receive( :start_args).and_return({})
      end

      subject { Docker::Template::Scratch.new(repo) }
      specify { expect(Docker::Image).to receive :build_from_dir }
      specify { expect(subject).to receive(:unlink).and_call_original }
      let(:repo) { Docker::Template::Repo.new("repo" => "scratch", "tag" => "latest") }
      specify(nil, :skip_build => true) { expect { silence_io { subject.build }}.not_to(raise_error) }
      specify(nil, :noisy => true) { expect(Docker::Template::Util).to receive(:notify_build) }
      specify { expect(Docker::Template::Ansi).to receive :clear }
      specify { expect(docker_image_mock).to receive :tag }
    end
  end
end
