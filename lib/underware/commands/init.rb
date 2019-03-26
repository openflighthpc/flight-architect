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

require 'json'
require 'underware/data_copy'
require 'underware/config'

module Underware
  module Commands
    class Init < CommandHelpers::BaseCommand
      LOGIN_GROUP = 'login'
      LOGIN_NODE_RANGE = 'gateway1'
      NODES_GROUP = 'nodes'
      NODES_RANGE = 'node[01-10]'

      allow_missing_current_cluster

      private

      def run
        switch_cluster
        DataCopy.overlay_to_cluster(nil, __config__.current_cluster).all
        unless options.bare
          DataCopy.overlay_to_cluster('example', __config__.current_cluster).all
          configure_domain

          # NOTE: The files created by the configure have been cached in
          # the `data/example` overlay. This code is being maintained for
          # posterity

          # configure_group(LOGIN_GROUP, LOGIN_NODE_RANGE)
          # configure_group(NODES_GROUP, NODES_RANGE)
          # configure_login_nodes
          template
        end
      end

      private

      def switch_cluster
        error_if_cluster_exists(args.first)
        CommandConfig.update { |c| c.current_cluster = args.first }
      end

      def configure_domain
        new_command(Configure::Domain).run!([], self.class.options)
      end

      # def configure_group(name, nodes)
      #   new_command(Configure::Group).run!(
      #     [name, nodes], load_answers_options("groups/#{name}.yaml")
      #   )
      # end

      # def configure_login_nodes
      #   reset_alces
      #   alces.groups.login.nodes.each do |node|
      #     new_command(Configure::Node).run!(
      #       [node.name], load_answers_options("nodes/gateway.yaml")
      #     )
      #   end
      # end

      def template
        new_command(Template).run!([], self.class.options)
      end

      def new_command(klass)
        klass.new
      end

      # def load_answers_options(relative_path)
      #   data = Data.load(FilePath.init_data(relative_path))
      #   json = JSON.dump(data)
      #   options = self.class.options
      #   options.default({ answers: json })
      #   options
      # end

      def error_if_cluster_exists(cluster)
        return unless cluster_exists?(cluster)
        raise InvalidInput, <<~ERROR.chomp
          Can not init '#{cluster}' as it already exists
        ERROR
      end
    end
  end
end
