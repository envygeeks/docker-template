# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Hooks
      module_function

      # Register a base and a name, so that people can add hooks onto
      # your base and name and you can call it later, this is agnostic as
      # to who is doing this, so any addition can add them.

      def register_name(base, name)
        @hooks ||= {}
        hooks = @hooks[base.to_s.downcase] = {}
        return false if hooks.key?(name.to_s)
        hooks[name.to_s] ||= Set.new
      end

      #

      def valid?(base, name)
        return false unless @hooks[base.to_s]
        return false unless @hooks[base.to_s][name.to_s]
        true
      end

      #

      def register(base, name, &block)
        return false unless block_given?
        raise Error::UnknownHookBaseOrName unless valid?(base, name)
        @hooks[base.to_s][name.to_s] << block
      end

      #

      def run(base, name, *datas)
        raise Error::UnknownHookBaseOrName unless valid?(base, name)
        @hooks[base.to_s][name.to_s].each do |hook|
          hook.call(*datas)
        end
      end

      # Allows us to defer loading internal hooks until we run those
      # specific hooks, that way if you take a path that doesn't need those
      # hooks, you can skip creating too much IO... like autoload.

      def load_internal(base, name)
        raise Error::UnknownHookBaseOrName unless valid?(base, name)
        hook_root = Template.gem_root.join("lib", "docker", "template", "hooks", base.to_s, name.to_s)
        return false unless hook_root.exist?
        hook_root.children.map do |hook|
          require hook
        end

        self
      end
    end
  end
end
