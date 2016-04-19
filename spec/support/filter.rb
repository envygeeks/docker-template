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
