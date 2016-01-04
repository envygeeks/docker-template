# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Utils do
  include_context :repos

  #

  describe "#notify_alias" do
    it "should have some color" do
      capture = capture_io { subject.notify_alias(mocked_repos.to_scratch) }
      expect(Simple::Ansi.has?(capture[:stdout])).to eq true
    end
  end

  #

  describe "#notify_build" do
    it "should output the user, tag and repo" do
      capture = capture_io { subject.notify_build(mocked_repos.to_repo) }
      expect(capture).to include({
        :stdout => %r!building:[:a-z\s]+/default:latest!i
      })
    end

    #

    context "(rootfs: true)" do
      it "should output a rootfs image if told to" do
        capture = capture_io do
          subject.notify_build(mocked_repos.to_repo, {
            rootfs: true
          })
        end

        #

        expect(capture).to include({
          :stdout => %r!building[:a-z\s]+/rootfs:default!i
        })
      end
    end
  end

  describe "#create_dockerhub_context" do
    before do
      template.send :copy_prebuild_and_verify

      silence_io do
        Docker::Template::Utils.create_dockerhub_context \
          template, template.context
      end
    end

    #

    let :template do
      mocked_repos.as :normal
      mocked_repos.to_normal
    end

    #

    it "should copy the context to the repo root" do
      expect(mocked_repos.to_repo.root.join("cache")).to exist
    end

    #

    after do
      template.unlink
    end
  end
end
