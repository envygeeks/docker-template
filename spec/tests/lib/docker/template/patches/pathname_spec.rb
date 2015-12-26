# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Pathname do
  include_context :repos

  subject do
    mocked_repos.as :normal
    Docker::Template.repos_root
  end

  #

  describe "#in_path?" do
    it "should report true if true" do
      expect(subject.in_path?(Dir.pwd)).to eq true
    end

    #

    context "when the dir/file doesn't exist" do
      it "should throw an error" do
        expect { Pathname.new("tmp").in_path?(Dir.pwd) }.to raise_error \
          Errno::ENOENT
      end
    end

    #

    context "when it's not in the root" do
      it "should return false" do
        expect(subject.in_path?(__dir__)).to eq false
      end
    end
  end

  #

  describe "#all_children" do
    it "should return all the (sub-)children of a folder" do
      expect(subject.all_children.map(&:to_s).sort).to eq \
        Dir.glob(Docker::Template.repos_root.join("**/*")).sort
    end
  end

  #

  describe "#glob" do
    it "should return Pathnames" do
      expect(subject.glob("**/*").first).to be_a Pathname
    end

    #

    it "works" do
      expect(subject.glob("**/*").map(&:to_s).sort).to eq \
        Dir.glob(Docker::Template.repos_root.join("**/*")).sort
    end
  end
end
