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

require 'underware/command_helpers/base_command'
require 'underware/command_helpers/node_identifier'

module Underware
  module Commands
    class Each < CommandHelpers::BaseCommand
      private

      prepend CommandHelpers::NodeIdentifier

      def setup
        @command = args[1]
      end

      attr_reader :command

      def run
        nodes.each do |node|
          rendered_cmd = node.render_string(command)
          opt = {
            out: $stdout.fileno ? $stdout.fileno : 1,
            err: $stderr.fileno ? $stderr.fileno : 2,
          }
          system(rendered_cmd, opt)
        end
      end
    end
  end
end
