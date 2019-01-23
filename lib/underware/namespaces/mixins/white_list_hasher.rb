
# frozen_string_literal: true

module Underware
  module Namespaces
    module Mixins
      module WhiteListHasher
        def self.included(base)
          base.extend(ClassMethods)
        end

        def self.convert_to_hash(obj)
          if obj.is_a?(Array)
            obj.map { |o| convert_to_hash(o) }
          elsif obj.respond_to?(:to_h)
            obj.to_h
          else
            obj
          end
        end

        module ClassMethods
          def method_added(name)
            super

            # Register hashable methods
            return if hasher_skip_method(reset: true)
            return if name == :initialize
            return unless public_method_defined?(name)
            if instance_method(name).arity == 0
              hashable_methods << name.to_sym
            end
          end

          def hashable_methods
            @hashable_methods ||= []
          end

          def hasher_skip_method(reset: false)
            if reset
              value = @hasher_skip_method
              @hasher_skip_method = false
              return value
            else
              @hasher_skip_method = true
            end
          end
        end

        def to_h
          self.class.hashable_methods.reduce({}) do |memo, method|
            value = __send__(method)
            hashed_value = WhiteListHasher.convert_to_hash(value)
            memo.merge(method => hashed_value)
          end
        end
      end
    end
  end
end
