# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

Docker::Template::Hooks.register :repo, :init do
  if !Docker::Template.config.build_types.include?(type)
    raise Docker::Template::Error::InvalidRepoType, \
      type
  end
end
