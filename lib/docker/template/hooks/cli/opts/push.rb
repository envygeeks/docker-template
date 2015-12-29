# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

Docker::Template::Hooks.register :cli, :opts do |parser, opts|
  parser.on("-p", "--[no-]push", "Push your repos after building them.") do |bool|
    opts["push"] = bool
  end
end
