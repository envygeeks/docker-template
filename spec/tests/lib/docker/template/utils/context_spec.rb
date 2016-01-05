# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Utils::Context do
  include_context :repos

  #

  describe "#context" do
    before do
      template.send :copy_prebuild_and_verify
      silence_io { described_class.context \
          template, template.context }
    end

    #

    let :template do
      mocked_repos.as :normal
      mocked_repos. to_normal
    end

    #

    it "should copy the context to the repo root" do
      repo = mocked_repos.to_repo
      expect(repo.root.join(repo.metadata[ \
        "cache_dir"])).to exist
    end

    #

    after do
      template.unlink
    end
  end
end
