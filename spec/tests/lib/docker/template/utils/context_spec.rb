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
      silence_io { described_class.cache \
          template, template.context }
    end

    #

    let :template do
      mocked_repos.as :normal
      mocked_repos. to_normal
    end

    #

    it "should cache the context" do
      expect(template.repo.cache_dir).to exist
    end

    #

    after do
      template.unlink
    end
  end
end
