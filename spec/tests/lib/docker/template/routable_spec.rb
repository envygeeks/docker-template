# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

require "rspec/helper"
describe Docker::Template::Routable do
  subject do
    Hello.new
  end

  #

  before :all do
    class Hello
      extend Docker::Template::Routable
      route_to_hash :world, :@hash, :hello
      route_to_ivar :not_shouting, :@ivar, revbool: true
      route_to_ivar :shouting, :@ivar, bool: true
      route_to_hash :hello, :@hash
      def initialize
        @ivar = "hello"
        @hash = {
          "hello" => "world"
        }
      end
    end
  end

  after :all do
    Object.send(:remove_const, :Hello)
  end

  #

  specify { expect(subject. world).to eq "world" }
  specify { expect(subject.shouting?).to eq true }
  specify { expect(subject. hello).to eq "world" }
  specify { expect(subject.not_shouting?).not_to \
    eq(subject.shouting?) }

  #

  it { is_expected.to respond_to :world }
  it { is_expected.to respond_to :not_shouting? }
  it { is_expected.to respond_to :shouting? }
  it { is_expected.to respond_to :hello }
end
