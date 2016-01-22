# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "rspec/helper"
describe Docker::Template do
  it { is_expected.to respond_to :config }
  it { is_expected.to respond_to :repos_root }
  it { is_expected.to respond_to :template_root }
  it { is_expected.to respond_to :gem_root }
  it { is_expected.to respond_to :root }
  it { is_expected.to respond_to :get }

  let :template do
    described_class
  end

  #

  include_context :repos do
    describe "#repo_is_root?" do
      context "when there is no repo dir" do
        it "should return true", :type => :normal, :layout => :simple do
          expect(template.repo_is_root?).to eq(
            true
          )
        end
      end
    end

    #

    describe "#repo_root_for" do
      context "when there is no repo dir" do
        it "should return the templates root as repo root", :type => :normal, :layout => :simple do
          expect(template.repo_root_for("normal")).to eq(
            template.root
          )
        end
      end
    end
  end

  #

  [:gem_root, :template_root, :repos_root, :root].each do |val|
    describe "##{val}" do
      it "should be a Pathame" do
        expect(template.send(val)).to be_a(
          Pathutil
        )
      end
    end
  end

  #

  describe "#config" do
    it "should be a always be a Config" do
      expect(template.config).to be_a(
        Docker::Template::Config
      )
    end
  end

  #

  describe "#get" do
    context "when no data is given" do
      it "should still return a string" do
        expect(template.get(:rootfs)).to be_a(
          String
        )
      end
    end

    #

    context "when data is given" do
      it "should parse that data with ERB" do
        expect(template.get(:rootfs, :rootfs_base_img => "hello world")).to start_with(
          "FROM hello world\n"
        )
      end
    end
  end
end
