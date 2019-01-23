
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
            return if name == :initialize
            if instance_method(name).arity == 0
              hashable_methods << name.to_s
            end
          end

          def hashable_methods
            @hashable_methods ||= []
          end
        end

        def to_h
          self.class.hashable_methods.reduce({}) do |memo, method|
            memo.merge(method => __send__(method))
          end
        end

        private

        def recursive_white_list_hash_methods
          method_results_hash(recursive_white_list_for_hasher)
            .transform_values(&:to_h)
        end

        def recursive_array_white_list_hash_methods
          method_results_hash(recursive_array_white_list_for_hasher)
            .transform_values { |array| array.map(&:to_h) }
        end

        # Turn an array of method names into a hash of method names to the
        # results of sending those methods to `self`.
        def method_results_hash(method_names)
          method_names.map do |method|
            [method, send(method)]
          end.to_h
        end

        def white_list_for_hasher
          self.class.white_list_for_hasher
        end

        def recursive_white_list_for_hasher
          raise NotImplementedError
        end

        def recursive_array_white_list_for_hasher
          raise NotImplementedError
        end
      end
    end
  end
end
