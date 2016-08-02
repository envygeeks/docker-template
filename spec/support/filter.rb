# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

RSpec.configure do |config|
  config.filter_run_excluding :ruby => (lambda do |type|
    RUBY_ENGINE == begin
      type == "!mri" || type == "!ruby" ? "ruby" : \
        if type == "!jruby"
          "jruby"
        end
    end
  end)
end
