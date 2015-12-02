# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Util::Copy do
  let(:tmp) { Pathname.new(Dir.mktmpdir) }
  let(:tmp_file) { Pathname.new(Tempfile.new("file-")).tap(&:unlink) }
  let(:copy) { described_class }
  subject { copy }

  def sym(num)
    Docker::Template.repos_root.join("sym#{num}/copy/rootfs")
  end

  after :each do
    tmp.rmtree
    if tmp_file.exist?
      then tmp_file.unlink
    end
  end

  describe "#directory" do
    context do
      subject { -> { copy.new(sym(1), tmp).directory }}
      specify { expect(&subject).to raise_error Errno::EPERM }
    end

    context do
      before { copy.new(sym(2), tmp).directory }
      subject { tmp.join("usr/local/bin/mkimg").symlink? }
      it { is_expected.to eq false }
    end
  end

  describe "#file" do
    context do
      subject { -> { copy.new(Docker::Template.repos_root.join("sym3/file"), tmp_file).file }}
      specify { expect(&subject).to raise_error Errno::EPERM }
    end

    context do
      subject { tmp_file }
      before { copy.new(file, tmp_file).file }
      let(:file) { Docker::Template.repos_root.join("../opts.yml") }
      specify { expect(subject.read).to eq file.read }
      it { is_expected.to exist }
    end

    context do
      subject { tmp_file }
      before { copy.new(file, tmp_file).file }
      let(:file) { Docker::Template.repos_root.join("sym4/opts.yml") }
      specify { expect(subject.read).to eq file.read }
      it { is_expected.to exist }
    end
  end
end
