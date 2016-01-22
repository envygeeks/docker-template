# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    module Error
      StandardError = Class.new(StandardError)
      autoload :BadRepoName, "docker/template/error/bad_repo_name"
      autoload :NoHookExists, "docker/template/error/no_hook_exists"
      autoload :BadExitStatus, "docker/template/error/bad_exit_status"
      autoload :InvalidTargzFile, "docker/template/error/invalid_targz_file"
      autoload :InvalidYAMLFile, "docker/template/error/invalid_yaml_file"
      autoload :NoSetupContext, "docker/template/error/no_setup_context"
      autoload :InvalidRepoType, "docker/template/error/invalid_repo_type"
      autoload :NoRootMetadata, "docker/template/error/no_root_metadata"
      autoload :NoRootfsMkimg, "docker/template/error/no_rootfs_mkimg"
      autoload :NotImplemented, "docker/template/error/not_implemented"
      autoload :RepoNotFound, "docker/template/error/repo_not_found"
    end
  end
end
