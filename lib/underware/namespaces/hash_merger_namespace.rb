
# frozen_string_literal: true

require 'underware/exceptions'
require 'underware/templating/renderer'
require 'underware/nodeattr_interface'
require 'underware/hash_mergers'

module Underware
  module Namespaces
    class HashMergerNamespace
      include Mixins::WhiteListHasher

      def initialize(alces, name = nil, platform: nil)
        @alces = alces
        @name = name
        @platform = platform&.to_sym
      end

      def config
        @config ||= run_hash_merger(alces.hash_mergers.config)
      end

      def answer
        @answer ||= run_hash_merger(alces.hash_mergers.answer)
      end

      def render_string(template_string, **dynamic_namespace)
        alces.render_string(
          template_string,
          **additional_dynamic_namespace,
          **dynamic_namespace
        )
      end

      def render_file(template_path, **dynamic_namespace)
        alces.render_file(
          template_path,
          **additional_dynamic_namespace,
          **dynamic_namespace
        )
      end

      private

      attr_reader :alces, :platform

      def white_list_for_hasher
        respond_to?(:name) ? [:name] : []
      end

      def recursive_white_list_for_hasher
        [:config, :answer]
      end

      def recursive_array_white_list_for_hasher
        []
      end

      def run_hash_merger(hash_obj)
        hash_obj.merge(**hash_merger_input) do |template|
          render_string(template)
        end
      end

      def hash_merger_input
        if platform
          {platform: platform}
        else
          {}
        end
      end

      def additional_dynamic_namespace
        raise NotImplementedError
      end
    end
  end
end
