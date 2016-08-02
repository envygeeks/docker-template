# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Auth do
  include_context :repos

  before :all do
    class AuthPathutilWrapper
      def expand_path
        self
      end

      #

      def read_json
        return {
          "auths" => {
            "server.com" => {
              "email" => "user@example.com",
              "auth"  => Base64.encode64(
                "username:password"
              )
            }
          }
        }
      end
    end
  end

  #

  before do
    allow(Pathutil).to receive(:new).and_call_original
    allow(described_class).to receive(:env?).and_return false
    allow(Docker).to receive(:authenticate!).and_return(nil)
    allow(Pathutil).to receive(:new).with("~/.docker/config.json") \
      .and_return(AuthPathutilWrapper.new)
  end

  #

  describe "#hub", :skip_auth => true do
    context "when it cannot authenticate" do
      before do
        allow(Docker).to receive :authenticate! do
          raise Docker::Error::AuthenticationError
        end
      end

      #

      it "should throw" do
        expect { described_class.hub }.to raise_error(
          Docker::Template::Error::UnsuccessfulAuth
        )
      end
    end
  end

  #

  describe "_hub_env" do
    before do
      allow(described_class).to receive(:env?).and_return true
      allow(ENV).to receive(:[]).with("DOCKER_SERVER").and_return("eserver.com")
      allow(ENV).to receive(:[]).with("DOCKER_EMAIL").and_return("euser@example.com")
      allow(ENV).to receive(:[]).with("DOCKER_PASSWORD").and_return("epassword")
      allow(ENV).to receive(:[]).with("DOCKER_USERNAME").and_return("eusername")
    end

    #

    it "should authenticate with those credentials" do
      expect(Docker).to receive(:authenticate!).with({
        "username" => "eusername",
        "serveraddress" => "eserver.com",
        "email" => "euser@example.com",
        "password" => "epassword"
      })
    end

    #

    context "when the user doesn't set a server" do
      before do
        allow(ENV).to receive(:[]).with("DOCKER_SERVER").and_return(
          nil
        )
      end

      #

      it "should use the default" do
        expect(Docker).to receive(:authenticate!).with({
          "username" => "eusername",
          "serveraddress" => described_class::DEFAULT_SERVER,
          "email" => "euser@example.com",
          "password" => "epassword"
        })
      end
    end
  end

  #

  context "_hub_config" do
    context "and the user has ~/.docker/config.json" do
      it "should read the file" do
        expect(Pathutil).to receive(:new).with("~/.docker/config.json").and_return(
          AuthPathutilWrapper.new
        )
      end

      #

      it "should auth with the credentials" do
        expect(Docker).to receive(:authenticate!).at_least(:once).with({
          "username" => "username",
          "serveraddress" => "server.com",
          "email" => "user@example.com",
          "password" => "password"
        })
      end
    end
  end

  #

  after do |ex|
    unless ex.metadata[:skip_auth]
      described_class.hub
    end
  end
end
