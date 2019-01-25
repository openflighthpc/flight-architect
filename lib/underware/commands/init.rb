# frozen_string_literal: true

#==============================================================================
#
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
        DataCopy.overlay_to_cluster(nil, Config.current_cluster).all
        unless options.bare
          DataCopy.overlay_to_cluster('example', Config.current_cluster).all
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
        Config.update { |c| c.current_cluster = args.first }
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
