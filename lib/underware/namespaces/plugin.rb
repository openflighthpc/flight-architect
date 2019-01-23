
# frozen_string_literal: true

require 'underware/namespaces/hash_merger_namespace'

# A Plugin namespace contains the values configured for a particular plugin for
# a particular node.

module Underware
  module Namespaces
    class Plugin < HashMergerNamespace
      attr_reader :node_namespace, :plugin

      delegate :name, to: :plugin

      # `answer` is defined in HashMergerNamespace, but is not meaningful for
      # this namespace (plugin answers are included within those for the
      # containing node namespace as a whole).
      undef :answer

      def initialize(plugin, node:)
        @node_namespace = node
        @plugin = plugin
        alces = node.send(:alces)
        @eager_render = alces.eager_render
        super(alces, plugin.name)
      end

      def config
        @config ||= run_hash_merger(plugin_config_hash_merger)
      end

      private

      attr_reader :eager_render

      def plugin_config_hash_merger
        HashMergers::PluginConfig.new(plugin: plugin, eager_render: eager_render)
      end

      def hash_merger_input
        # The plugin config should be merged in the same order as specified in
        # the containing node namespace.
        node_namespace.send(:hash_merger_input)
      end

      def additional_dynamic_namespace
        { node: node_namespace }
      end
    end
  end
end
