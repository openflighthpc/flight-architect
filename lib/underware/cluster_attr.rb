# frozen_string_literal: true

# =============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Architect.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Architect is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Architect. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Architect, please visit:
# https://github.com/openflighthpc/flight-architect
# ==============================================================================

require 'flight_config'
require 'nodeattr_utils'

module Underware
  class ClusterAttr
    include FlightConfig::Updater

    class << self
      def filename
        'cluster-attributes'
      end

      def expand(nodes)
        NodeattrUtils::NodeParser.expand(nodes)
      end

      # TODO: Actually collapse the nodes array instead of joining them
      # as a single string
      def collapse(*nodes)
        nodes.flatten.join(',')
      end
    end

    attr_reader :cluster

    def initialize(cluster)
      @cluster = cluster
      __data__.set_if_empty(:groups, value: ['orphan'])
    end

    def path
      DataPath.cluster(cluster).join('var', self.class.filename + '.yaml')
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
      raw_groups.reject(&:nil?).map do |group|
        [group, group_index(group)]
      end.to_h
    end

    def group_index(group)
      return nil if group.nil?
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

    def nodes_in_primary_group(group)
      nodes_list.select { |n| groups_for_node(n).first == group }
    end

    def add_group(group_name)
      return if raw_groups.include?(group_name)
      __data__.append(group_name, to: :groups)
    end

    def remove_group(group_name)
      error_if_removing_orphan_group(group_name)
      nodes_list.select { |n| groups_for_node(n).first == group_name }
                .join(',')
                .tap { |node_str| remove_nodes(node_str) }
      __data__.fetch(:groups).map! { |g| g == group_name ? nil : g }
    end

    def add_nodes(node_string, groups: [])
      groups = Array.wrap(groups)
      add_group(groups.first) unless groups.empty?
      self.class.expand(node_string).each do |node|
        __data__.set(:nodes, node, value: groups)
      end
    end

    def remove_nodes(node_string)
      self.class.expand(node_string).map do |node|
        __data__.delete(:nodes, node)
      end
    end

    def orphans
      nodes_in_group('orphan')
    end

    private

    def error_if_removing_orphan_group(group)
      return unless group == 'orphan'
      raise ClusterAttrError, <<~ERROR.chomp
        Can not remove the orphan group
      ERROR
    end
  end
end
