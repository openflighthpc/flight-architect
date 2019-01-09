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

require 'underware/cluster_attr/expand'
require 'tty/config'

module Underware
  class ClusterAttr
    class << self
      def expand(nodes_string)
        Expand.explode_nodes(nodes_string)
      end

      def update(*a)
        new(*a).tap do |cluster_attr|
          cluster_attr.config.write
        end
      end
    end

    attr_reader :cluster, :config

    def initialize(cluster)
      @cluster = cluster
      @config = TTY::Config.new
      config.prepend_path(FilePath.internal_data_dir)
      config.filename = 'cluster-attributes'
      setup
    end

    def setup
      config.set_if_empty(:groups, value: ['orphan'])
      config.set_if_empty(:nodes, value: {})
    end

    def raw_groups
      config.fetch(:groups)
    end

    def raw_nodes
      config.fetch(:nodes).keys
    end

    def group_index(group)
      raw_groups.find_index(group)
    end

    def groups_for_node(node)
      config.fetch(:nodes, node)
    end

    def add_group(group_name)
      raise_error_if_group_exists(group_name)
      config.append(group_name, to: :groups)
    end

    def add_nodes(node_string, groups: [])
      groups = Array.wrap(groups)
      self.class.expand(node_string).each do |node|
        raise_error_if_node_exists(node)
        config.set(:nodes, node, value: groups)
      end
    end

    private

    def raise_error_if_node_exists(node)
      if config.fetch(:nodes, node)
        raise ExistingNodeError, <<~ERROR
          Failed to add node as it already exists: '#{node}'
        ERROR
      end
    end

    def raise_error_if_group_exists(group)
      if config.fetch(:groups).include?(group)
        raise ExistingGroupError, <<~ERROR
          Failed to add group as it already exists: '#{group}'
        ERROR
      end
    end
  end
end
