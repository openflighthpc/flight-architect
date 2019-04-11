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
                          ClusterAttr.load(__config__.current_cluster)
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
