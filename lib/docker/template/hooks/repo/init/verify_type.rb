# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

Docker::Template::Hooks.register :repo, :init do |repo|
  if !Docker::Template.config.build_types.include?(repo.type)
    raise Docker::Template::Error::InvalidRepoType, \
      repo.type
  end
end
