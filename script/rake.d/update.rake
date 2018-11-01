# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

$LOAD_PATH.unshift(File.expand_path(
  "../lib", __FILE__
))

# --

require "simple/ansi"
require "docker/template/cli"
require "open3"

# --
# TODO: Cleanup and remove this whenever you can.
# --
module CompList
  module_function

  # --
  # Update the pak file to have all the completions.
  # --
  def update(data = get_commands, msgp = data.to_msgpack)
    pak_file.binwrite(
      msgp
    )
  end

  # --

  def normalize_command(command)
    if command.is_a?(Array)
      then command.map do |key|
        key.tr(
          "_", "-"
        )
      end
    else
      command.tr(
        "_", "-"
      )
    end
  end

  # --
  # Provides the base "_reply" for your auto-complete data output.
  # --
  def base(const, skip = %w(help))
    keys = const.all_commands.keys
    return "_reply" => normalize_command(keys), "help" => {
      "_reply" => normalize_command(keys) - skip
    }
  end

  # --

  def add_opts(out, const)
    const.all_commands.each do |key, val, command = normalize_command(key)|
      val.options.map do |_, opt|
        out[command] ||= { "_reply" => [] }
        ary = out[command][
          "_reply"
        ]

        if !opt.boolean?
          ary << "#{
            opt.switch_name
          }="

        else
          ary << opt.switch_name
          ary << "--no-#{opt.switch_name.gsub(
            /\A--/, ""
          )}"
        end

        ary | opt.aliases
      end
    end

    out
  end

  # --
  # Recursively pulls out and set's up your commands and opts.
  # --
  def get_commands(const = Docker::Template::CLI)
    out = base(
      const
    )

    const.subcommands.each do |key, command = normalize_command(key)|
      const_list = const.to_namespace.push(command.to_namespace)
      out[command] = send(__method__, Thor::Namespace.resolv(
        const_list
      ))
    end

    add_opts(
      out, const
    )
  end

  # --

  def pak_file
    Pathutil.new("comp/list.pak").expand_path.tap(
      &:touch
    )
  end
end

# --

namespace :update do
  desc "Update the completion list."
  task "comp-list" do
    require "msgpack"
    require "docker/template"
    CompList.update
  end
end
