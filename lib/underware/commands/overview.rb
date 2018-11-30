# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
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

require 'terminal-table'
require 'underware/overview/table'

module Underware
  module Commands
    class Overview < CommandHelpers::BaseCommand
      private

      attr_reader :overview_data

      def setup
        @overview_data = Data.load FilePath.overview
      end

      def run
        print_domain_table
        print_groups_table
      end

      def print_domain_table
        fields = overview_data[:domain]
        puts Underware::Overview::Table.new([alces.domain], fields).render
      end

      def print_groups_table
        fields_from_yaml = overview_data[:group]
        name_field = { header: 'Group Name', value: '<%= group.name %>' }
        fields = [name_field].concat fields_from_yaml
        puts Underware::Overview::Table.new(alces.groups, fields).render
      end
    end
  end
end
