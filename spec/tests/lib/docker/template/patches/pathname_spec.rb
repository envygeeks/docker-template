# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Pathname do
  let(:root) { Docker::Template.repos_root }
  subject { root }

  describe "#in_path?" do
    subject { root.in_path?(Dir.pwd) }
    it { is_expected.to eq true }

    context "when it doesn't exist" do
      subject { -> { Pathname.new("tmp").in_path?(Dir.pwd) }}
      specify { expect(&subject).to raise_error Errno::ENOENT }
    end

    context "when it's not in the root" do
      subject { root.in_path?("/tmp") }
      it { is_expected.to eq false }
    end
  end

  describe "#all_children" do
    subject { root.all_children.map(&:to_s).sort }
    it { is_expected.to eq Dir.glob(Docker::Template.repos_root.join("**/*")).sort }
  end

  describe "#glob" do
    subject { root.glob("**/*") }
    specify { expect(subject.map(&:to_s).sort).to eq Dir.glob(Docker::Template.repos_root.join("**/*")).sort }
    specify { expect(subject.first).to be_a Pathname }
  end
end
