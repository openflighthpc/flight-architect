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
          attr = ClusterAttr.update(__config__.current_cluster) do |a|
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
          existing_nodes = ClusterAttr.load(__config__.current_cluster).nodes_list
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
