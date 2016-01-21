# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Utils::Copy do
  include_context :repos

  #

  subject do
    described_class
  end

  #

  before do
    mocked_repo.init({
      :layout => :simple,
      :type   => :normal
    })
  end

  #

  describe "#directory" do
    let :tmpdir do
      [
        Pathutil.new(Dir.mktmpdir),
        Pathutil.new(Dir.mktmpdir).tap(
          &:rm_rf
        )
      ]
    end

    #

    after :each do
      tmpdir.map do |dir|
        dir.rm_rf rescue nil
      end
    end

    #

    context "when the symlink is not in the path" do
      before do
        mocked_repo.external_symlink(
          tmpdir.first, "copy/hello"
        )
      end

      #

      it "should raise a permission error" do
        expect { subject.directory(mocked_repo.join("copy"), tmpdir.last) }.to \
          raise_error Errno::EPERM
      end
    end

    #

    context do
      before do
        mocked_repo.symlink("copy/hello", "copy/world")
        mocked_repo.  touch("copy/hello")
        subject.directory(mocked_repo.join("copy"), \
          tmpdir.first)
      end

      #

      it "should copy it" do
        expect(tmpdir.first.join("world")).to exist
      end

      #

      it "should resolve it" do
        expect(tmpdir.first.join("world").symlink?).to \
          eq false
      end
    end
  end

  describe "#file" do
    let :tmpfile do
      [
        Pathutil.new(Tempfile.new("file-")),
        Pathutil.new(Tempfile.new("file-")).tap(
          &:rm_rf
        )
      ]
    end

    #

    after :each do
      tmpfile.map do |file|
        file.rm_rf rescue nil
      end
    end

    #

    context "when the symlink is not in the path" do
      before do
        mocked_repo.external_symlink(
          tmpfile.first, "copy/hello"
        )
      end

      #

      it "should raise a permission error" do
        expect { subject.file(mocked_repo.join("copy/hello"), tmpfile.last) }.to \
          raise_error Errno::EPERM
      end
    end

    #

    context do
      before do
        mocked_repo.symlink("copy/hello", "copy/world")
        mocked_repo.  touch("copy/hello")
        subject.file(mocked_repo.join("copy/world"), \
          tmpfile.first)
      end

      #

      it "should copy it" do
        expect(tmpfile.first).to exist
      end

      #

      it "should resolve it" do
        expect(tmpfile.first.symlink?).to \
          eq false
      end
    end
  end
end
