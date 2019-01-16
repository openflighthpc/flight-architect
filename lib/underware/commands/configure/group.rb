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

require 'underware/command_helpers/configure_command'
require 'underware/constants'
require 'underware/cluster_attr'
require 'underware/group_list_parser'

module Underware
  module Commands
    module Configure
      class Group < CommandHelpers::ConfigureCommand
        private

        attr_reader :group_name, :cache, :groups, :nodes_string

        def setup
          @group_name = args.first
          @nodes_string = args[1]
          @groups = parse_groups
        end

        def configurator
          @configurator ||=
            Configurator.for_group(alces, group_name)
        end

        def answer_file
          FilePath.group_answers(group_name)
        end

        def custom_configuration
          ClusterAttr.update(Underware::Config.current_cluster) do |attr|
            attr.add_group(group_name)
            attr.add_nodes(nodes_string, groups: groups)
          end
        end

        def parse_groups
          GroupListParser.parse("#{group_name},#{options.groups}")
        end
      end
    end
  end
end
