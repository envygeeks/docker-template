# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Util::System do
  describe ".docker_bin?" do
    it "should return true if 0 is Docker" do
      expect(described_class.docker_bin?("docker")).to eq true
    end

    #

    context "with a bad value" do
      it "should not throw; return false" do
        expect(described_class.docker_bin?(nil)).to eq false
      end
    end
  end

  #

  describe ".docker_bin" do
    let :tmpbin do
      Dir.mktmpdir("bin")
    end

    #

    before do
      file = File.join(tmpbin, "docker")
      ENV["PATH"] = "#{tmpbin}:#{ENV["PATH"]}"
      FileUtils.touch file
      FileUtils.chmod("u+rx", \
        file)
      end

    #

    it "should find the Docker binary" do
      expect(described_class.docker_bin).to match %r!\/docker\Z!
    end

    #

    after do
      FileUtils.rm_rf(tmpbin)
    end

    #

    context "with a bad path" do
      before do
        ENV["PATH"] = "/hello/world/bin:#{ENV["PATH"]}"
      end

      #

      it "should not raise an error" do
        expect { described_class.docker_bin }.not_to \
          raise_error
      end
    end
  end
end
