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

module Underware
  module Commands
    module Remove
      class Group < CommandHelpers::BaseCommand
        private

        attr_reader :group_name, :nodes

        def setup
          @group_name = args.first
          @nodes = ClusterAttr.load(Config.current_cluster)
                              .nodes_in_primary_group(group_name)
        end

        def run
          delete_group
          delete_answer_files
        end

        def delete_group
          ClusterAttr.update(Config.current_cluster) do |attr|
            attr.remove_group(group_name)
          end
        end

        def delete_answer_files
          data_path = DataPath.cluster(Config.current_cluster)
          FileUtils.rm(data_path.group_answers(group_name))
          nodes.each { |n| FileUtils.rm(data_path.node_answers(n)) }
        end
      end
    end
  end
end
