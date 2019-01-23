
# frozen_string_literal: true

module Underware
  module Namespaces
    module Mixins
      module WhiteListHasher
        def self.included(base)
          base.extend(ClassMethods)
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
            memo.merge(method => __send__(method))
          end
        end
      end
    end
  end
end
