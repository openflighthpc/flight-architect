
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

module Underware
  module Namespaces
    class Group < HashMergerNamespace
      include Mixins::Name

      attr_reader :index

      def initialize(*args, index:)
        @index = index
        super(*args)
      end

      def nodes
        @nodes ||= begin
          arr = alces.cluster_attr.nodes_in_group(name).map do |node_name|
            alces.nodes.send(node_name)
          end
          UnderwareArray.new(arr)
        end
      end

      def hostlist_nodes
        Underware::ClusterAttr.collapse(*nodes.map(&:name))
      end

      private

      def hash_merger_input
        super.merge(groups: [name])
      end

      def additional_dynamic_namespace
        { group: self }
      end
    end
  end
end
