# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
require "active_support/core_ext/string/strip"
describe Docker::Template::CLI::List do
  include_contexts :repos

  #

  subject do
    Simple::Ansi.strip(described_class.build).gsub(
      /(├─ |│)/, ""
    )
  end

  #

  before do
    mocked_repo.clear_opts.with_opts({
      :user => :user,
      :tags => {
        :tag => :normal
      }
    })
  end

  #

  it "should color everything for readability" do
    expect(Simple::Ansi.has?(described_class.build)).to eq(
      true
    )
  end

  #

  it "should output user, repo, and tags" do
    expect(subject).to eq <<-STR.strip_heredoc
      [user] user
        [repo] default
          [tag] tag
    STR
  end

  #

  context "when given a true remote" do
    before do
      mocked_repo.with_opts({
        :aliases => {
          :alias => "remote/repo:tag"
        }
      })
    end

    #

    it "should output aliases under that true remote" do
      expect(subject).to eq <<-STR.strip_heredoc
        [user] user
          [repo] default
            [tag] tag
            [remote] remote/repo:tag
              [alias] alias
      STR
    end
  end

  #

  context "when a tag has aliases" do
    before do
      mocked_repo.with_opts({
        :aliases => {
          :alias => :tag
        }
      })
    end

    #

    it "should output the aliases inside of the tag" do
      expect(subject).to eq <<-STR.strip_heredoc
        [user] user
          [repo] default
            [tag] tag
              [alias] alias
      STR
    end
  end
end
