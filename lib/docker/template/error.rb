# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Error
      StandardError = Class.new(StandardError)
    end
  end
end

require "docker/template/error/bad_repo_name"
require "docker/template/error/no_hook_exists"
require "docker/template/error/bad_exit_status"
require "docker/template/error/invalid_targz_file"
require "docker/template/error/invalid_yaml_file"
require "docker/template/error/no_setup_context"
require "docker/template/error/invalid_repo_type"
require "docker/template/error/no_root_metadata"
require "docker/template/error/no_rootfs_mkimg"
require "docker/template/error/not_implemented"
require "docker/template/error/repo_not_found"
