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

require 'underware/cluster_attr'

module Underware
  module CommandHelpers
    module NodeIdentifier
      private

      MISSING_GENDER_WARNING = 'Could not find nodes for gender: '
      MISSING_NODE_WARNING = 'Could not find node: '

      attr_reader :node_identifier

      def pre_setup(*a)
        super(*a)
        @node_identifier = args.first
      end

      def nodes
        raise_missing unless node_names
        @nodes ||= node_names.map { |n| alces.nodes.find_by_name(n) }
      end

      def node_names
        @node_names ||= if options.gender
                          ClusterAttr.load('something')
                                     .nodes_in_group(node_identifier)
                        else
                          [node_identifier]
                        end
      end

      def raise_missing
        msg = warning + node_identifier
        raise InvalidInput, msg
      end

      def warning
        options.gender ? MISSING_GENDER_WARNING : MISSING_NODE_WARNING
      end
    end
  end
end
