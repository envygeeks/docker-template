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
    context "when told to cache a non-aliased image" do
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

    #

    context "when told to cache an aliased image" do
      subject do
        mocked_repo.to_normal
      end

      #

      before do
        mocked_repo.add_alias :hello
        mocked_repo.with_repo_init :tag => :hello
        mocked_repo.with_opts :cache => true

        silence_io do
          subject.aliased_repo.builder.send :setup
          described_class.aliased_context(
            subject
          )
        end
      end

      #

      it "should copy it's parent's context", :type => :normal do
        expect(subject.repo.cache_dir).to(
          exist
        )
      end

      #

      after do
        subject.aliased_repo.builder.teardown
      end
    end
  end
end
