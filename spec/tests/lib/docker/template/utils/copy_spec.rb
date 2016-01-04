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
    mocked_repos.as :simple_normal
  end

  #

  describe "#directory" do
    let :tmpdir do
      [
        Pathname.new(Dir.mktmpdir),
        Pathname.new(Dir.mktmpdir) \
          .tap(&:rmtree)
      ]
    end

    #

    after :each do
      tmpdir.map do |dir|
        dir.rmtree rescue nil
      end
    end

    #

    context "when the symlink is not in the path" do
      before do
        dir = mocked_repos.join("copy/hello")
        mocked_repos.external_symlink(tmpdir.first, dir)
      end

      #

      it "should raise a permission error" do
        expect { subject.directory(mocked_repos.join("copy"), tmpdir.last) }.to \
          raise_error Errno::EPERM
      end
    end

    #

    context do
      before do
        mocked_repos.symlink("copy/hello", "copy/world")
        mocked_repos.  touch("copy/hello")
        subject.directory(mocked_repos.join("copy"), \
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
        Pathname.new(Tempfile.new("file-")),
        Pathname.new(Tempfile.new("file-")) \
          .tap(&:unlink)
      ]
    end

    #

    after :each do
      tmpfile.map do |file|
        file.unlink rescue nil
      end
    end

    #

    context "when the symlink is not in the path" do
      before do
        file = mocked_repos.join("copy/hello")
        mocked_repos.external_symlink(tmpfile.first, file)
      end

      #

      it "should raise a permission error" do
        expect { subject.file(mocked_repos.join("copy/hello"), tmpfile.last) }.to \
          raise_error Errno::EPERM
      end
    end

    #

    context do
      before do
        mocked_repos.symlink("copy/hello", "copy/world")
        mocked_repos.  touch("copy/hello")
        subject.file(mocked_repos.join("copy/world"), \
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
