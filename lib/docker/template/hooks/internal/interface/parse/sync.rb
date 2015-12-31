# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

Docker::Template::Hooks.register :interface, :parse do |parser|
  parser.on("-s", "--[no-]sync", "Sync repos to the cache dir") do |bool|
    @argv["dockerhub_cache"] = bool
  end
end
