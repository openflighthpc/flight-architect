
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
require 'underware/command_helpers/base_command'

module Underware
  module CommandHelpers
    class InspectCommand < BaseCommand
      private

      def pretty_print_json(json)
        # Delegate pretty printing with colours to `jq`.
        Open3.popen2(jq_command) do |stdin, stdout|
          stdin.write(json)
          stdin.close
          puts stdout.read
        end
      end

      def jq_command
        "jq . #{colourize_output? ? '--color-output' : ''}"
      end

      def colourize_output?
        # Should colourize the output if we have been forced to do so or we are
        # outputting to a terminal.
        options.color_output || STDOUT.isatty
      end
    end
  end
end
