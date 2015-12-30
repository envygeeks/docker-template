# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

Docker::Template::Hooks.register :metadata, :init do |metadata|
  if !metadata.root? && !metadata.root_metadata
    raise Docker::Template::Error::NoRootMetadata
  end
end
