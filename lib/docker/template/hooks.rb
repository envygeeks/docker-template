# Frozen-string-literal: true
# Copyright: 2015 Jordon Bedwell - Apache v2.0 License
# Encoding: utf-8

module Docker
  module Template
    module Hooks
      attr_reader :hooks
      extend Forwardable
      @hooks = Set.new
      extend self

      #

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

      def register_point(point, klass)
        other = klass.name.to_s.split(/::/).last.downcase
        point = point.to_s

        unless get_point(klass, point)
          @hooks << {
            :point => point,
            :alternate_klass => other,
            :hooks => Set.new,
            :klass => klass
          }
        end
      end

      #

      def register(klass, point, order: 99, &block)
        ensure_exist! klass, point

        struct = hook_struct.new
        point = get_point(klass, point)
        struct.name = generate_hook_name
        point[:klass]::HookMethods.send(:define_method, struct.name, &block)
        point[:hooks] << struct
        struct.order = order
      end

      #

      def run(context, point, *args)
        ensure_exist! context, point
        load_internal context, point

        # Make sure we order it by the order that the user wants it to come in as.
        get_point(context, point).fetch(:hooks).sort_by { |struct| struct.order }.each do |struct|
          context.send(struct.name, *args)
        end
      end

      #

      def get_point(base, point)
        @hooks.find do |hash|
          base.is_a?(hash[:klass]) || base.to_s == hash[:alternate_klass] \
            && point.to_s == hash[:point]
        end
      end

      #

      def ensure_exist!(base, point)
        unless get_point(base, point)
          raise Error::NoHookExists.new(base, point)
        end
      end

      # Allows us to defer loading internal hooks until we run those
      # specific hooks, that way if you take a path that doesn't need those
      # hooks, you can skip creating too much IO... like autoload.

      private
      def load_internal(base, point)
        root = internal_root.join(*get_point(base, point).values_at(:alternate_klass, :point))
        return unless root.exist?

        root.children.map do |file|
          require file
        end
      end

      #

      private
      def hook_struct
        @struct ||= Struct.new(:order, :name)
      end

      #

      private
      def internal_root
        @root ||= Template.gem_root.join("lib", "docker", "template", \
          "hooks", "internal")
      end

      #

      private
      def generate_hook_name
        return SecureRandom.hex(12)
      end
    end
  end
end
