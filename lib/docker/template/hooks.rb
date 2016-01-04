# Frozen-string-literal: true
# Copyright: 2015 - 2016 Jordon Bedwell - Apache v2.0 License
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
        other = klass.name.to_s.split(/::/.freeze).last.downcase
        point = point.to_s

        unless get_point(klass, point)
          @hooks << {
            :point => point,
            :alternate_klass => other,
            :hooks => Set.new,
            :klass => klass
          }.freeze
        end
      end

      #

      def register(klass, point, order: 99, &block)
        ensure_exist! klass, point

        point = get_point(klass, point)
        struct = Struct.new(:order, :name).new(order, rand_hook_name)
        point[:klass]::HookMethods.send(:define_method, struct.name, &block)
        point[:hooks] << struct
      end

      #

      def run(context, point, *args)
        ensure_exist! context, point
        get_point(context, point).fetch(:hooks).sort_by(&:order).each do |struct|
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

      #

      private
      def rand_hook_name
        SecureRandom.hex(12)
      end
    end
  end
end
