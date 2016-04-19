# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "rspec/helper"
describe Docker::Template::CLI::Build do
  include_context :repos

  before do
    allow(Docker::Template::Repo).to receive(:build)   .and_return nil
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

  context "initializing", :start => false do
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

  context "when the user wishes to build only diffs", :ruby => "!jruby" do
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

  context "when the user wishes to profile", :ruby => "!jruby" do
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
        def pretty_print(*args)
          return
        end
      end
    end

    #

    before do
      allow(MemoryProfiler).to receive(:report).and_return(
        ProfilerMock.new
      )
    end

    #

    it "should profile" do
      expect(MemoryProfiler).to receive(:report).and_return(
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

  after do |ex|
    unless ex.metadata[:start] == false
      subject.start
    end
  end
end
