# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

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
        Set
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

  describe "#to_repo_hash" do
    context "when given a valid identifier" do
      specify do
        expect(subject.new.send(:to_repo_hash, "repo:tag")).to \
          include({
            "name" => "repo"
          })
      end

      #

      specify do
        expect(subject.new.send(:to_repo_hash, "repo:tag")).to \
          include({
            "tag" => "tag"
          })
      end

      #

      specify do
        # user/repo:tag
        expect(subject.new.send(:to_repo_hash, "user/repo:tag")).to \
          include({
            "user" => "user"
          })
      end

      #

      specify do
        expect(subject.new.send(:to_repo_hash, "user/repo:tag")).to \
          include({
            "name" => "repo"
          })
      end

      #

      specify do
        expect(subject.new.send(:to_repo_hash, "user/repo:tag")).to \
          include({
            "tag" => "tag"
          })
      end

      #

      specify do
        expect(subject.new.send(:to_repo_hash, "user/repo")).to \
          include({
            "user" => "user"
          })
      end

      #

      specify do
        expect(subject.new.send(:to_repo_hash, "user/repo")).to \
          include({
            "name" => "repo"
          })
      end

      #

      specify do
        expect(subject.new.send(:to_repo_hash, "repo")).to \
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

        it "should output Templates" do
          expect(subject.new(%w(default)).parse.first).to be_a(
            Docker::Template::Repo
          )
        end
      end
    end
  end
end
