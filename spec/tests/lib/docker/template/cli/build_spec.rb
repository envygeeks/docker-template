# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "rspec/helper"
describe Docker::Template::CLI::Build do
  include_context :repos

  before do
    allow(Docker::Template::Repo).to receive(:build).and_return(
      nil
    )
  end

  #

  let :parser do
    Docker::Template::Parser
  end

  #

  subject do
    described_class.new(
      [], {}
    )
  end

  #

  describe "#initialize", :start => false do
    it "pulls the repositories" do
      expect(parser).to receive(:new).with([], {}) \
        .and_call_original
    end

    #

    it "parses the repositories" do
      expect_any_instance_of(parser).to receive(:parse) \
        .and_call_original
    end

    #

    after do
      described_class.new(
        [], {}
      )
    end
  end

  #

  describe "#start" do
    it "profiles by default" do
      expect(subject).to receive(:_profile) \
        .and_call_original
    end
  end

  #

  context "--diff or diff: true", :ruby => "!jruby" do
    it "should reselect the repositories" do
      expect(subject).to receive(:reselect_repos).and_return(
        []
      )
    end

    #

    subject do
      described_class.new([], {
        :diff => true
      })
    end
  end

  #

  context "--profile or profile: true", :ruby => "!jruby" do
    before :all do
      require "memory_profiler"
    end

    #

    subject do
      described_class.new([], {
        :profile => true
      })
    end

    #

    before :all do
      class ProfilerMock
        def pretty_print(*)
          return
        end
      end
    end

    #

    before do
      allow(MemoryProfiler).to receive(:report) \
        .and_return(
          ProfilerMock.new
        )
    end

    #

    it "should profile" do
      expect(MemoryProfiler).to receive(:report) \
        .and_return(
          ProfilerMock.new
        )
    end

    #

    it "should report" do
      expect_any_instance_of(ProfilerMock).to receive(
        :pretty_print
      )
    end
  end

  #

  describe "#reselect_repos", :start => false, :ruby => "!jruby" do
    before do
      # Require uses #_require so we need to shim that out.
      allow(Docker::Template).to receive(:require).with("rugged").and_return(
        true
      )
    end

    #

    let :git do
      require "rugged"
      Rugged::Repository.init_at(
        mocked_repo.root.to_s
      )
    end

    #

    before do
      git.config.store "user.email", "user@example.com"
      git.config.store "user.name", "Some User"
      git.index.add_all

      Rugged::Commit.create git, {
        :message => "Init.",
        :tree => git.index.write_tree(git),
        :update_ref => "HEAD",
        :parents => []
      }

      mocked_repo.add_tag "latest"
      mocked_repo.join("repos/hello").mkdir_p
      mocked_repo.join("repos/hello/opts.yml").write({
        "tags" => {
          "latest" => "normal"
        }
      }.to_yaml)
    end

    #

    it "should pull repositories from the last commit" do
      expect_any_instance_of(Rugged::Repository).to receive(:last_commit) \
        .and_call_original
    end

    #

    it "should return all modified repositories" do
      expect(subject.reselect_repos.count).to eq 1
      expect(subject.reselect_repos.first.name).to eq(
        "default"
      )
    end

    #

    context "when argv = [val, val]" do
      it "should drop repos from that list that are not modified" do
        expect(described_class.new(%w(hello default), {}).reselect_repos.count).to eq(
          1
        )
      end
    end

    #

    after do
      subject.reselect_repos
    end
  end

  #

  after do |ex|
    unless ex.metadata[:start] == false
      subject.start
    end
  end
end
