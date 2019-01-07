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

module Underware
  module Commands
    class Init < CommandHelpers::BaseCommand
      LOGIN_GROUP = 'login'
      NODES_GROUP = 'nodes'

      private

      def setup; end

      def run
        # Run the domain configuration
        configure_domain
        configure_login_group
        configure_nodes_group
        configure_login_nodes
        template
      end

      private

      def configure_domain
        new_command(Configure::Domain).run!([], self.class.options)
      end

      def configure_login_group
        new_command(Configure::Group).run!(
          [LOGIN_GROUP], load_answers_options("groups/#{LOGIN_GROUP}.yaml")
        )
      end

      def configure_nodes_group
        new_command(Configure::Group).run!(
          [NODES_GROUP], load_answers_options("groups/#{NODES_GROUP}.yaml")
        )
      end

      def configure_login_nodes
        reset_alces
        alces.groups.login.nodes.each do |node|
          new_command(Configure::Node).run!(
            [node.name], load_answers_options("nodes/gateway.yaml")
          )
        end
      end

      def template
        reset_alces
        new_command(Template).run!([], self.class.options)
      end

      def new_command(klass)
        klass.new(noop: true, alces: alces)
      end

      def load_answers_options(relative_path)
        data = Data.load(FilePath.init_data(relative_path))
        json = JSON.dump(data)
        options = self.class.options
        options.default({ answers: json })
        options
      end
    end
  end
end
