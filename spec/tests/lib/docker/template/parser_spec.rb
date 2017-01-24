# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Parser do
  include_context :repos

  #

  subject do
    described_class
  end

  #

  before do
    mocked_repo.init({
      :type => :normal
    })
  end

  #

  describe "#parse" do
    it "should output a set" do
      expect(subject.new.parse).to be_a(
        Array
      )
    end

    #

    context "when given a bad identifier" do
      it "should throw" do
        expect { subject.new(["invalid/user/repo:tag"]).parse }.to raise_error(
          Docker::Template::Error::BadRepoName
        )
      end

      #

      it "should throw" do
        expect { subject.new(["user/repo:tag:double_tag"]).parse }.to raise_error(
          Docker::Template::Error::BadRepoName
        )
      end
    end
  end

  #

  describe ".to_repo_hash" do
    context "when given a valid identifier" do
      specify do
        expect(subject.send(:to_repo_hash, "repo:tag")).to \
          include({
            "name" => "repo"
          })
      end

      #

      specify do
        expect(subject.send(:to_repo_hash, "repo:tag")).to \
          include({
            "tag" => "tag"
          })
      end

      #

      specify do
        # user/repo:tag
        expect(subject.send(:to_repo_hash, "user/repo:tag")).to \
          include({
            "user" => "user"
          })
      end

      #

      specify do
        expect(subject.send(:to_repo_hash, "user/repo:tag")).to \
          include({
            "name" => "repo"
          })
      end

      #

      specify do
        expect(subject.send(:to_repo_hash, "user/repo:tag")).to \
          include({
            "tag" => "tag"
          })
      end

      #

      specify do
        expect(subject.send(:to_repo_hash, "user/repo")).to \
          include({
            "user" => "user"
          })
      end

      #

      specify do
        expect(subject.send(:to_repo_hash, "user/repo")).to \
          include({
            "name" => "repo"
          })
      end

      #

      specify do
        expect(subject.send(:to_repo_hash, "repo")).to \
          include({
            "name" => "repo"
          })
      end

      #

      context do
        before do
          mocked_repo.with_opts({
            :tags => {
              "latest" => "normal"
            }
          })
        end

        #

        it "should output Templates" do
          expect(subject.new(%w(default)).parse.first).to be_a(
            Docker::Template::Repo
          )
        end
      end
    end
  end

  #

  describe ".full_name?" do
    context "when given repo/image:tag" do
      it "should return true" do
        expect(subject.full_name?("repo/image:tag")).to eq(
          true
        )
      end
    end

    #

    context "when given repo/image" do
      it "should return true" do
        expect(subject.full_name?("repo/image")).to eq(
          true
        )
      end
    end

    #

    context "when given repo:tag" do
      it "should return true" do
        expect(subject.full_name?("repo:tag")).to eq(
          true
        )
      end
    end

    #

    context "when given just a user/repo" do
      it "should return false" do
        expect(subject.full_name?("nothing")).to eq(
          false
        )
      end
    end
  end

  #

  describe "#all" do
    context "when given raw repos" do
      it "should return those" do
        expect(described_class.new(%w(hello)).all).to eq %w(
          hello
        )
      end
    end

    #

    context "when it's project" do
      before do
        allow(Docker::Template).to receive(:project?).and_return(
          true
        )
      end

      #

      subject do
        described_class.new
      end

      #

      it "should return the single root" do
        expect(subject.all.size).to eq 1
        expect(subject.all).to include(
          Docker::Template.root.basename.to_s
        )
      end
    end
  end
end
