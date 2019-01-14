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

        attr_reader :group_name, :cache, :groups

        def setup
          @group_name = args.first
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
          node_range, genders = configured_nodes_and_genders
          ClusterAttr.update('something') do |attr|
            attr.add_group(group_name)
            attr.add_nodes(node_range, groups: groups)
          end
        end

        def configured_nodes_and_genders
          reset_alces
          new_group = Namespaces::Group.new(alces, group_name, index: nil)
          genders = [
            group_name,
            new_group.config.role,
            new_group.answer.secondary_groups,
            'all'
          ]
          [new_group.answer.hostname_range.to_s, genders]
        end

        def parse_groups
          GroupListParser.parse("#{group_name},#{options.groups}")
        end
      end
    end
  end
end
