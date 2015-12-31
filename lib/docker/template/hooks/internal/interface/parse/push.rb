# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

Docker::Template::Hooks.register :interface, :parse do |parser|
  parser.on("-p", "--[no-]push", "Push your repos after building them.") do |bool|
    @argv["push"] = bool
  end
end
