# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Util
      class Copy
        def initialize(from, to)
          @root = Template.root.realpath
          @repos_root = Template.repo_is_root?? Template.root.realpath : Template.repos_root.realpath
          @from = from.to_pathname
          @to = to.to_pathname
        end

        #

        def self.directory(from, to)
          if from && to && File.exist?(from)
            new(from, to).directory
          end
        end

        # Copy a directory checking for symlinks and resolving them (only
        # at the top level) if they are in the repos root, the root or the from
        # path. The reason we check all three is because repos might be a
        # symlink that resolves out of path so we need to allow symlinks
        # from it. The same for the copy folder.

        def directory
          FileUtils.cp_r(@from.children, @to, :dereference_root => false)
          @from.all_children.select(&:symlink?).each do |path|
            resolved = path.realpath
            pth = path.relative_path_from(@from)
            pth = @to.join(path)

            unless in_path?(resolved)
              raise Errno::EPERM, "#{pth} not in #{@root}"
            end

            FileUtils.rm_r(pth)
            FileUtils.cp_r(resolved, pth, {
              :dereference_root => false
            })
          end
        end

        #

        def self.file(from, to)
          if to && from && File.exist?(from)
            new(from, to).file
          end
        end

        #

        def file
          if !@from.symlink?
            return FileUtils.cp(@from, @to)
          end

          resolved = @from.realpath
          allowed = resolved.in_path?(@root)
          raise Errno::EPERM, "#{resolved} not in #{@root}." unless allowed
          FileUtils.cp(resolved, @to)
        end

        # Check to see if the path falls within the users roots, while
        # getting the real path of the from root just incase it, itself is
        # a symlink, we don't want it to fail because of that.

        private
        def in_path?(resolved)
          resolved.in_path?(@repos_root) || \
          resolved.in_path?(@from.realpath) || \
          resolved.in_path?(@root)
        end
      end
    end
  end
end
