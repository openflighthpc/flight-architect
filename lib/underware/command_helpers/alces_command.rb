
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

require 'underware/exceptions'

module Underware
  module CommandHelpers
    module AlcesCommand
      private

      attr_reader :raw_alces_command

      def setup
        @raw_alces_command = args.first
      end

      def alces_command
        @alces_command = begin
          alces_command_split.reduce(alces) { |acc, elem| acc.send(elem) }
        end
      end

      ALCES_COMMAND_DELIM = /[\.]/
      ALCES_COMMAND_REGEX = \
        /\A([[:alnum:]]#{ALCES_COMMAND_DELIM}?)*[[:alnum:]]\Z/

      def alces_command_split
        arr = raw_alces_command.split(ALCES_COMMAND_DELIM)
        arr.shift if /\A#{arr[0]}/.match?('alces')
        alces_command_replace_short_methods(arr)
        arr
      end

      def alces_command_replace_short_methods(arr)
        ['nodes', 'groups', 'domain'].each do |method|
          next unless /\A#{arr[0]}/.match?(method)
          arr.shift
          arr.unshift(method)
          break
        end
      end
    end
  end
end
