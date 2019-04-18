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

require 'underware/command_helpers/configure_command'
require 'underware/constants'

module Underware
  module Commands
    module Configure
      class Node < CommandHelpers::ConfigureCommand
        private

        attr_reader :node_name

        def setup
          @node_name = args.first
        end

        def configurator
          @configurator ||=
            Configurator.for_node(alces, node_name)
        end

        def answer_file
          FilePath.node_answers(node_name)
        end

        def custom_configuration
          return if alces.nodes.find_by_name(node_name)
          ClusterAttr.update(__config__.current_cluster) do |attr|
            attr.add_nodes(node_name)
          end
        end
      end
    end
  end
end
