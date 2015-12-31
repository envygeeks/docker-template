# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

Docker::Template::Hooks.register :repo, :init do
  unless root.exist?
    raise Docker::Template::Error::RepoNotFound
  end
end
