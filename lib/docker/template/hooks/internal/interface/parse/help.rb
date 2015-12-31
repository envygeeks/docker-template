# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

Docker::Template::Hooks.register :interface, :parse do |parser|
  parser.on("-h", "--help", "Show this message") do
    $stdout.puts parser
    exit 0
  end
end
