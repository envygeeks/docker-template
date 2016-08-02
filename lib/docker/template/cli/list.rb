module Docker
  module Template
    class CLI
      class List
        def self.build
          return new.build
        end

        # --

        def initialize(images = Parser.new([], {}).parse)
          @images = images
        end

        # --

        def build
          out = ""

          @images.group_by(&:user).each do |user, images|
            out += "[user] " + Simple::Ansi.blue(user) + "\n" + repos(
              user, images
            )
          end

          out
        end

        # --

        def repos(user, images)
          out = ""

          images.group_by(&:name).each do |name, _|
            out += "  ├─ [repo] " + Simple::Ansi.green(name) + "\n"
            out += tags(user, name, images)
            out += remote_aliases(
              user, name, images
            )
          end

          out
        end

        # --

        def tags(user, name, images)
          out = ""

          images.select { |image| image.name == name && image.user == user && !image.alias? }.each do |image|
            out += "  │  ├─ [tag] " + Simple::Ansi.magenta(image.tag) + "\n"
            out += aliases(
              user, name, image.tag, images
            )
          end

          out
        end

        # --

        def remote_aliases(*args)
          out = ""

          remotes = _remote_aliases(*args).group_by do |image|
            image.meta[:aliases][
              image.tag
            ]
          end

          remotes.each do |remote, images_|
            out += "  │  ├─ [remote] "
            out += Simple::Ansi.yellow(remote)
            out += "\n"

            images_.each do |image|
              out += "  │  │  ├─ [alias] "
              out += Simple::Ansi.yellow(
                image.tag
              )

              out += "\n"
            end
          end

          out
        end

        # --

        def _remote_aliases(user, name, images)
          images.select do |image|
            image.user == user && image.name == name && aliased_remote?(
              image
            )
          end
        end

        # --

        def aliases(user, name, tag, images, depth: 0)
          out = ""

          _aliases(user, name, tag, images).each do |alias_|
            name_ = \
              if alias_.name == name
                Simple::Ansi.yellow(
                  alias_.tag
                )

              else
                Simple::Ansi.yellow(
                  "#{alias_.name}:#{alias_.tag}"
                )
              end

            out += "  │  │  #{"│  " * depth}├─ [alias] #{name_}\n"
            out += aliases(user, name, alias_.tag, images, {
              :depth => depth + 1
            })
          end

          out
        end

        # --

        private
        def aliased_remote?(image)
          return image.alias? && !image.aliased
        end

        # --

        private
        def _aliases(user, name, tag, images)
          images.select do |image|
            image.alias? && image.aliased && image.aliased.tag == tag \
              && image.aliased.name == name && image.aliased.user \
                == user
          end
        end
      end
    end
  end
end
