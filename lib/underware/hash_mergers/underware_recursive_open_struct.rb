
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
  module HashMergers
    class UnderwareRecursiveOpenStruct
      include Enumerable

      def initialize(table, eager_render:, &input_block)
        @table = table
        @eager_render = eager_render
        @convert_string_block = input_block || proc { |s| s }
      end

      delegate :key?, to: :table

      def method_missing(s, *_a, &_b)
        return nil unless respond_to_missing?(s)
        value = self[s]
        define_singleton_method(s) { value }
        value
      end

      def respond_to_missing?(s, *_a)
        table.key?(s)
      end

      def [](key)
        value = table[key]
        convert_value(value)
      end

      def each
        table.each_key { |key| yield(key, send(key)) }
      end

      def each_value
        each { |_s, value| yield value } # rubocop:disable Performance/HashEachMethods
      end

      def to_h
        eager_render? ? eager_rendered_to_h : table
      end

      def to_json(*_a)
        to_h.to_json
      end

      private

      attr_reader :table, :eager_render, :convert_string_block
      alias_method :eager_render?, :eager_render

      def convert_value(value)
        case value
        when String
          convert_string_block.call(value)
        when Hash
          self.class.new(
            value, eager_render: eager_render, &convert_string_block
          )
        when Array
          value.map { |arg| convert_value(arg) }
        else
          value
        end
      end

      def eager_rendered_to_h
        table.map do |k, v|
          converted = convert_value(v)
          converted = converted.to_h if converted.is_a?(self.class)
          [k, converted]
        end.to_h
      end
    end
  end
end
