
# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2019 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Underware.
#
# Alces Underware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Underware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Underware, please visit:
# https://github.com/alces-software/underware
#==============================================================================

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
