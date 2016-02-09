# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "rspec/helper"
describe Docker::Template::Cache do
  include_context :repos

  #

  describe "#context" do
    before do
      subject.send :setup
      silence_io do
        described_class.context(
          subject, subject.context
        )
      end
    end

    #

    subject do
      mocked_repo.to_normal
    end

    #

    it "should cache the context", :type => :normal do
      expect(subject.repo.cache_dir).to(
        exist
      )
    end

    #

    after do
      subject.teardown
    end
  end
end
