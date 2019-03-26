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
  module Commands
    module Remove
      class Group < CommandHelpers::BaseCommand
        private

        attr_reader :group_name, :nodes

        def setup
          @group_name = args.first
          @nodes = ClusterAttr.load(__config__.current_cluster)
                              .nodes_in_primary_group(group_name)
        end

        def run
          delete_group
          delete_answer_files
        end

        def delete_group
          ClusterAttr.update(__config__.current_cluster) do |attr|
            attr.remove_group(group_name)
          end
        end

        def delete_answer_files
          data_path = DataPath.cluster(__config__.current_cluster)
          FileUtils.rm_f(data_path.group_answers(group_name))
          nodes.each { |n| FileUtils.rm_f(data_path.node_answers(n)) }
        end
      end
    end
  end
end
