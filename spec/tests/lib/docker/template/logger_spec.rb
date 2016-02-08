# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "rspec/helper"
describe Docker::Template::Logger do
  subject do
    described_class
  end

  #

  def log(type, what)
    io = capture_io { described_class.new.api(what.to_json) }
    type == :both ? io : io[type]
  end

  #

  include_context :repos do
    describe "#output" do
      before do
        mocked_repo.with_opts("log_filters" => [
          /hello/
        ])
      end

      it "should be able to filter messages" do
        expect(described_class.new(mocked_repo.to_normal).send(:output, "hello world")).to(
          be_nil
        )
      end
    end
  end

  #

  describe "#progress_bar" do
    subject do
      log :stderr, {
        "progress" => "world",
        "id"       => "hello"
      }
    end

    #

    it "should prefix with the id and then message" do
      expect(Simple::Ansi.strip(subject).strip).to eq(
        "hello: world"
      )
    end

    #

    context "when no ID is present" do
      subject do
        log :stdout, {
          "progress" => "world"
        }
      end

      it "should not log" do
        expect(subject).to(
          be_empty
        )
      end
    end
  end

  #

  describe "#api" do
    context "when it's a stream" do
      subject do
        log :stdout, {
          "stream" => "hello\nworld"
        }
      end

      #

      it "should output what it gets" do
        expect(subject).to eq(
          "hello\nworld\n"
        )
      end
    end

    #

    context "when a message is not handled" do
      subject do
        log :both, {
          "unknown" => "hello"
        }
      end

      #

      it "should spit out the inspect of the message" do
        expect(subject[:stdout].strip).to eq({
          "unknown" => "hello"
        }.to_json)
      end

      #

      it "should log an error message" do
        expect(subject[:stderr]).not_to(
          be_empty
        )
      end
    end
  end
end
