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
