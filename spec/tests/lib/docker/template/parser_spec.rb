# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Parser do
  let(:parser) { described_class }
  subject { parser }

  before do
    allow_any_instance_of(parser).to receive(:parse).and_wrap_original do |method, *args|
      args.unshift({}) unless args[0]
      args[0][:as] = :hash unless args[0].has_key?(:as)
      method.call(*args)
    end
  end

  context do
    subject { parser.new.parse }
    specify { expect(subject.size).to eq Docker::Template.repos_root.children.size }
    it { is_expected.to be_a Set }
  end

  specify do
    error = Docker::Template::Error::BadRepoName
    expect_it = expect { subject.new(["invalid/user/repo:tag"]).parse }
    expect_it.to raise_error error
  end

  specify do
    error = Docker::Template::Error::BadRepoName
    expect_it = expect { subject.new(["user/repo:tag:double_tag"]).parse }
    expect_it.to raise_error error
  end

  context do
    subject { parser.new(["user/repo"]).parse.first }
    it { is_expected.to include "user" => "user" }
    it { is_expected.to include "repo" => "repo" }
  end

  context do
    subject { parser.new(["repo"]).parse.first }
    it { is_expected.to include "repo" => "repo" }
  end

  context do
    subject { described_class.new(["repo:tag"]).parse.first }
    it { is_expected.to include "tag"  =>  "tag" }
    it { is_expected.to include "repo" => "repo" }
  end

  context do
    subject { described_class.new(["user/repo:tag"]).parse.first }
    it { is_expected.to include "repo" => "repo" }
    it { is_expected.to include "tag"  =>  "tag" }
    it { is_expected.to include "user" => "user" }
  end

  context do
    subject { described_class.new(["repo", "user/repo", "user/repo:tag"]).parse.to_a }
    specify { expect(subject[0]).to include "repo" => "repo" }
    specify { expect(subject[1]).to include "repo" => "repo" }
    specify { expect(subject[1]).to include "user" => "user" }
    specify { expect(subject[2]).to include "tag"  =>  "tag" }
    specify { expect(subject[2]).to include "user" => "user" }
    specify { expect(subject[2]).to include "repo" => "repo" }
  end

  context do
    specify { expect(subject.first).to be_a Docker::Template::Repo }
    subject { described_class.new(["scratch", "simple"]).parse(as: :repos) }
    it { is_expected.to be_a Set }
  end

  context "when repos folder does not exist" do
    specify { expect(&subject).to raise_error Docker::Template::Error::RepoNotFound }
    before { allow(Docker::Template).to receive(:repos_root).and_return(Pathname.new("/non-exitent")) }
    subject { -> { parser.new.all }}
  end
end
