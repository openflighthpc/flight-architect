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
          @groups = parse_groups
          error_if_existing_nodes
        end

        def configurator
          @configurator ||=
            Configurator.for_group(alces, group_name)
        end

        def answer_file
          FilePath.group_answers(group_name)
        end

        def custom_configuration
          attr = ClusterAttr.update(Underware::Config.current_cluster) do |a|
            a.add_group(group_name)
            a.add_nodes(nodes, groups: groups) if nodes
          end
          return if attr.nodes_in_group(group_name).any?
          msg = <<~WARN.squish
            Configured '#{group_name}' without any nodes. Re-run the following
            command to add some:
          WARN
          cmd = "#{APP_NAME} configure group #{group_name} <NODES>"
          UnderwareLog.warn [msg, cmd].join("\n")
        end

        def parse_groups
          GroupListParser.parse("#{group_name},#{options.groups}")
        end

        def nodes
          args[1] if args.length > 1
        end

        def error_if_existing_nodes
          existing_nodes = ClusterAttr.load(Config.current_cluster).nodes_list
          duplicates = ClusterAttr.expand(nodes) & existing_nodes
          return if duplicates.empty?
          raise InvalidInput, <<~ERROR.squish.chomp
            Can not configure group as the following node(s) already exist:
            #{duplicates.join(',')}
          ERROR
        end
      end
    end
  end
end
