# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8
# ----------------------------------------------------------------------------

module Docker
  module Template
    class Rootfs < Builder
      extend Forwardable::Extended

      # ----------------------------------------------------------------------

      def data
        Template.get(:rootfs, {
          :rootfs_base_img => @repo.metadata["rootfs_base_img"]
        })
      end

      # ----------------------------------------------------------------------

      def builder_data
        tpl = "rootfs/#{@repo.metadata.rootfs_template}"
        erb = @repo.root.join("rootfs.erb")

        Template.get(
          erb.file?? erb : tpl, {
            :metadata => @repo.metadata
          }
        )
      end

      # ----------------------------------------------------------------------
      # During a simple copy you store all the data (including rootfs) data
      # as a single unit, this helps us clean up data that is known to be for
      # just the rootfs image and remove it so it doesn't impact.
      # ----------------------------------------------------------------------

      def simple_cleanup(dir)
        file = dir.join("usr/local/bin/mkimg")

        if file.exist?
          then file.delete
        end
      end

      # ----------------------------------------------------------------------

      def teardown(img: true)
        @context.rmtree if @context && @context.directory?
        @img.delete "force" => true if @img && img \
          rescue nil
      end

      # ----------------------------------------------------------------------

      private
      def setup_context
        @context = @repo.tmpdir("rootfs")
        @copy = @context.join(@repo.metadata["copy_dir"])
        @context.join("Dockerfile").write(data)

        @copy.join("usr/local/bin").mkdir_p
        @copy.join("usr/local/bin/mkimg").write(builder_data)
        @copy.join("usr/local/bin/mkimg").chmod(0755)
        copy_rootfs
      end

      # ----------------------------------------------------------------------

      private
      def copy_rootfs
        dir = @repo.copy_dir(
          "rootfs"
        )

        if dir.exist?
          @repo.copy_dir("rootfs").safe_copy(@copy, {
            :root => Template.root
          })
        end
      end
    end
  end
end
