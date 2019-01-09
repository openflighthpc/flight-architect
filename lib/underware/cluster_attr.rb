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
    end

    attr_reader :cluster

    def initialize(cluster)
      @cluster = cluster
      @config = TTY::Config.new
      config.prepend_path(FilePath.internal_data_dir)
      config.filename = 'cluster-attributes'
      setup
    end

    def setup
      config.set_if_empty(:groups, value: ['orphan'])
      config.set_if_empty(:nodes, value: [])
    end

    def raw_groups
      config.fetch(:groups)
    end

    def raw_nodes
      config.fetch(:nodes)
    end

    def group_index(group)
      raw_groups.find_index(group)
    end

    def add_group(group_name)
      config.append(group_name, to: :groups)
    end

    def add_nodes(node_string)
      node_array = self.class.expand(node_string)
      config.append(*node_array, to: :nodes)
    end

    private

    attr_reader :config
  end
end
