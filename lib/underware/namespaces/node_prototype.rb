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

require 'underware/namespaces/plugin'
require 'underware/system_command'

module Underware
  module Namespaces
    class NodePrototype < HashMergerNamespace
      include Namespaces::Mixins::Name

      def initialize(*a, genders: nil)
        super(*a)
        @genders = genders
      end

      def genders
        @genders ||= []
      end

      def group
        @group ||= alces.groups.send(genders.first)
      end

      def index
        @index ||= begin
          group.nodes.each_with_index do |other_node, index|
            return index + 1 if other_node == self
          end
          raise InternalError, 'Node does not appear in its primary group'
        end
      end

      def kickstart_url
        @kickstart_url ||= DeploymentServer.kickstart_url(name)
      end

      def build_complete_url
        @build_complete_url ||= DeploymentServer.build_complete_url(name)
      end

      def genders_url
        @genders_url ||= DeploymentServer.system_file_url('genders')
      end

      def plugins
        @plugins ||= UnderwareArray.new(enabled_plugin_namespaces)
      end

      private

      def hash_merger_input
        super.merge(node_hash_merger_input)
      end

      def node_hash_merger_input
        { groups: genders, node: name }
      rescue NodeNotInGendersError
        # The answer hash needs to be accessible by the Configurator. Nodes in
        # a group work fine as they appear in the genders file BUT
        # orphan nodes DO NOT appear in the genders file and cause the above
        # error.
        { groups: ['orphan'], node: name }
      end

      def additional_dynamic_namespace
        { node: self }
      end

      def enabled_plugin_namespaces
        Plugins.activated.map do |plugin|
          Namespaces::Plugin.new(plugin, node: self) if plugin_enabled?(plugin)
        end.compact
      end

      def plugin_enabled?(plugin)
        answer.send(plugin.enabled_question_identifier)
      end
    end
  end
end
