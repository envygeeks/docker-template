# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Config do
  subject do
    Docker::Template.config
  end

  #

  describe "#initialize" do
    Docker::Template::Config::DEFAULTS.each do |key, _|
      specify { expect(subject.key?(key)).to eq true }
    end
  end

  #

  describe "#read_config_from" do
    include_context :repos do
      before do
        mocked_repos.as(:normal).with_opts({
          "maintainer" => "Some Girl <lyfe@thug.programmer>"
        })
      end

      subject do
        root = mocked_repos.to_repo.root
        Docker::Template.config.read_config_from(root)
      end

      #

      it "should read the configuration" do
        expect(subject).to include({
          "maintainer" => "Some Girl <lyfe@thug.programmer>"
        })
      end

      #

      context "when empty" do
        before do
          mocked_repos.write("opts.yml", "")
        end

        it "returns a hash" do
          expect(subject).to be_a Hash
        end
      end

      context "when non-existant" do
        it "returns a hash" do
          expect(subject).to be_a Hash
        end
      end

      context "when invalid" do
        before do
          mocked_repos.write("opts.yml", "[hello]")
        end

        it "should raise an error" do
          expect { mocked_repos.to_repo }.to raise_error \
            Docker::Template::Error::InvalidYAMLFile
        end
      end
    end
  end

  describe "#build_types" do
    it "returns an array of build types" do
      expect(subject.build_types).to be_an Array
    end
  end

  #

  describe "#has_default?" do
    it "should return true if the value is in DEFAULTS" do
      expect(subject.has_default?("user")).to eq true
    end

    #

    context "with a non-existant key" do
      it "should return false" do
        expect(subject.has_default?("hello")).to eq false
      end
    end
  end

  it { is_expected.to respond_to :keys }
  it { is_expected.to respond_to :to_h }
  it { is_expected.to respond_to :to_enum }
  it { is_expected.to respond_to :key? }
  it { is_expected.to respond_to :each }
  it { is_expected.to respond_to :[] }
end
