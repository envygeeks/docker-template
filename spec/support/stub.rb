# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

RSpec.configure do |config|
  config.before do
    dir = Pathname.new(File.expand_path("../data", __dir__))
    allow(Docker::Template).to(receive(:repos_root).and_return(dir.join(Docker::Template.config["repos_dir"])))
    allow(Docker::Template).to(receive(:root).and_return(dir))
    allow(Dir).to receive(:pwd).and_return(dir)
  end
end
