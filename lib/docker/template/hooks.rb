# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Hooks
      attr_reader :hooks
      extend Forwardable
      extend self
      @hooks = {}

      #

      autoload :Wrapper, "docker/template/hooks/wrapper"
      autoload :Methods, "docker/template/hooks/methods"

      #

      def_delegator :@hooks, :key?
      def_delegator :@hooks, :each
      def_delegator :@hooks, :inspect
      def_delegator :@hooks, :find_by
      def_delegator :@hooks, :to_enum
      def_delegator :@hooks, :to_h
      def_delegator :@hooks, :[]

      # Register a base and a name, so that people can add hooks onto
      # your base and name and you can call it later, this is agnostic as
      # to who is doing this, so any addition can add them.

      def register_name(base, point)
        point = point.to_s
        base  =  base.to_s

        @hooks[base] ||= {}
        return false if @hooks[base].key?(point)
        @hooks[base][point] ||= Set.new
      end

      #

      def verify!(base, point)
        unless valid?(base, point)
          raise Error::NoHookExists.new(base, point)
        end
      end

      #

      def valid?(base, point)
        point = point.to_s
        base  =  base.to_s

        return false unless key?(base)
        return false unless @hooks[base].key?(point)
        true
      end

      #

      def register(base, point, name = :unknown, order = 99, &block)
        base  =  base.to_s
        point = point.to_s
        name  =  name.to_s

        verify!(base, point)
        return false unless block_given?
        @hooks[base][point] << Wrapper.new(name, block, order)
      end

      #

      def run(base, point, *datas)
        point = point.to_s
        base  =  base.to_s

        verify!(base, point)
        @hooks[base][point].each do |hook|
          hook.call(*datas)
        end
      end

      #

      def run_with_context(base, point, context, *datas)
        point = point.to_s
        base  =  base.to_s

        verify!(base, point)
        @hooks[base][point].each do |hook|
          context.instance_exec(*datas, &hook.source)
        end
      end

      # Allows us to defer loading internal hooks until we run those
      # specific hooks, that way if you take a path that doesn't need those
      # hooks, you can skip creating too much IO... like autoload.

      def load_internal(base, point)
        point = point.to_s
        base  =  base.to_s

        verify!(base, point)
        hook_root = Template.gem_root.join("lib", "docker", "template", "hooks", "internal", base, point)
        return self unless hook_root.exist?
        hook_root.children.map do |hook|
          require hook
        end

        self
      end
    end
  end
end
