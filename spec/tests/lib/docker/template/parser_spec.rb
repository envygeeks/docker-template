# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
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
    mocked_repos.as :normal
    allow_any_instance_of(Docker::Template::Parser).to receive(:parse). \
        and_wrap_original do |method, *args|

      args.unshift({}) unless args[0]
      args[0][:as] = :hash unless args[0].key?(:as)
      method.call(*args)
    end
  end

  #

  describe "#parse" do
    it "should output a set" do
      expect(subject.new.parse).to be_a Set
    end

    #

    context "when given a bad identifier" do
      it "should throw" do
        expect { subject.new(["invalid/user/repo:tag"]).parse }.to \
          raise_error Docker::Template::Error::BadRepoName
      end

      #

      it "should throw" do
        expect { subject.new(["user/repo:tag:double_tag"]).parse }.to \
          raise_error Docker::Template::Error::BadRepoName
      end
    end

    #

    context "when given a valid identifier" do
      let :array do
        %w(
          repo:tag
          user/repo:tag
          user/repo
          repo
        )
      end

      #

      specify do
        expect(subject.new(array).parse.to_a[0]).to \
        include({
          "repo" => "repo"
        })
      end

      #

      specify do
        expect(subject.new(array).parse.to_a[0]).to \
        include({
          "tag" => "tag"
        })
      end

      #

      specify do
        expect(subject.new(array).parse.to_a[1]).to \
        include({
          "user" => "user"
        })
      end

      #

      specify do
        expect(subject.new(array).parse.to_a[1]).to \
        include({
          "repo" => "repo"
        })
      end

      #

      specify do
        expect(subject.new(array).parse.to_a[1]).to \
        include({
          "tag" => "tag"
        })
      end

      #

      specify do
        expect(subject.new(array).parse.to_a[2]).to \
        include({
          "user" => "user"
        })
      end

      #

      specify do
        expect(subject.new(array).parse.to_a[2]).to \
        include({
          "repo" => "repo"
        })
      end

      #

      specify do
        expect(subject.new(array).parse.to_a[3]).to \
        include({
          "repo" => "repo"
        })
      end

      #

      it "should output Templates" do
        # Technically `as: :repos` is the default, @see `before`
        expect(subject.new(%w(default)).parse(as: :repos).first).to \
          be_a Docker::Template::Repo
      end
    end
  end
end
