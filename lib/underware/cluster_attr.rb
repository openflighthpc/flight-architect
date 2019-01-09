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
          cluster_attr.__data__.write
        end
      end
    end

    attr_reader :cluster, :__data__

    def initialize(cluster)
      @cluster = cluster
      @__data__ = TTY::Config.new
      __data__.prepend_path(FilePath.internal_data_dir)
      __data__.filename = 'cluster-attributes'
      setup
    end

    def setup
      __data__.set_if_empty(:groups, value: ['orphan'])
      __data__.set_if_empty(:nodes, value: {})
    end

    def raw_groups
      __data__.fetch(:groups)
    end

    def raw_nodes
      __data__.fetch(:nodes).keys
    end

    def group_index(group)
      raw_groups.find_index(group)
    end

    def groups_for_node(node)
      __data__.fetch(:nodes, node)
    end

    def add_group(group_name)
      raise_error_if_group_exists(group_name)
      __data__.append(group_name, to: :groups)
    end

    def add_nodes(node_string, groups: [])
      groups = Array.wrap(groups)
      self.class.expand(node_string).each do |node|
        raise_error_if_node_exists(node)
        __data__.set(:nodes, node, value: groups)
      end
    end

    private

    def raise_error_if_node_exists(node)
      if __data__.fetch(:nodes, node)
        raise ExistingNodeError, <<~ERROR
          Failed to add node as it already exists: '#{node}'
        ERROR
      end
    end

    def raise_error_if_group_exists(group)
      if __data__.fetch(:groups).include?(group)
        raise ExistingGroupError, <<~ERROR
          Failed to add group as it already exists: '#{group}'
        ERROR
      end
    end
  end
end
