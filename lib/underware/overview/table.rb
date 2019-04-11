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

module Underware
  module Overview
    class Table
      attr_reader :fields
      attr_reader :namespaces

      def initialize(namespaces, fields)
        @fields = fields
        @namespaces = namespaces
      end

      def render
        Terminal::Table.new(headings: headers, rows: rows).render
      end

      private

      def headers
        fields.map { |f| f[:header] }
      end

      def unrendered_values
        fields.map { |f| f[:value] || '' }
      end

      def rows
        namespaces.map { |namespace| row(namespace) }
      end

      def row(namespace)
        unrendered_values.map do |value|
          namespace.render_string(value)
        end
      end
    end
  end
end
