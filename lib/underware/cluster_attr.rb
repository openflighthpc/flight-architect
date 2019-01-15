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
require 'underware/patches/tty_config'

module Underware
  class ClusterAttr
    class << self
      def filename
        'cluster-attributes'
      end

      def expand(nodes)
        # Do not expand single nodes as the libray can not handle it
        nodes.include?('[') ? Expand.explode_nodes(nodes) : [nodes]
      end

      # TODO: Actually collapse the nodes array instead of joining them
      # as a single string
      def collapse(*nodes)
        nodes.flatten.join(',')
      end

      def update(*a)
        new(*a).tap do |attr|
          attr.__data__.read unless attr.__data__.source_file.nil?
          yield attr if block_given?
          attr.__data__.write(force: true)
        end
      end
      alias_method :load, :update
    end

    attr_reader :cluster, :__data__

    def initialize(cluster)
      @cluster = cluster
      @__data__ = TTY::Config.new
      __data__.prepend_path(FilePath.underware_storage)
      __data__.filename = self.class.filename
      setup
    end

    def setup
      __data__.set_if_empty(:groups, value: ['orphan'])
    end

    def raw_groups
      __data__.fetch(:groups)
    end

    def raw_nodes
      __data__.fetch(:nodes, default: {})
    end

    def nodes_list
      raw_nodes.keys
    end

    def groups_hash
      raw_groups.map do |group|
        [group, group_index(group)]
      end.to_h
    end

    def group_index(group)
      raw_groups.find_index(group)
    end

    def groups_for_node(node)
      __data__.fetch(:nodes, node, default: []).dup.tap do |groups|
        groups.push 'orphan' if groups.empty?
      end
    end

    def nodes_in_group(group)
      nodes_list.select { |node| groups_for_node(node).include?(group) }
    end

    def add_group(group_name)
      return if raw_groups.include?(group_name)
      __data__.append(group_name, to: :groups)
    end

    def add_nodes(node_string, groups: [])
      groups = Array.wrap(groups)
      self.class.expand(node_string).each do |node|
        __data__.set(:nodes, node, value: groups)
      end
    end

    def orphans
      nodes_in_group('orphan')
    end
  end
end
