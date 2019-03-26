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
require 'open3'
require 'underware/underware_log'

module Underware
  module SystemCommand
    class << self
      # This is just a slightly more robust version of Kernel.`, so we get an
      # exception that must be handled or be displayed if the command run
      # fails.
      #
      # `format_error` option specifies whether any error produced should be
      # formatted suitably for displaying to a user.
      def run(command, format_error: true)
        stdout, stderr, status = capture3(command)
        if status.exitstatus != 0
          handle_error(command, stderr, format_error: format_error)
        else
          stdout
        end
      end

      def no_capture(command)
        UnderwareLog.info("SystemCommand: #{command}")
        system(command)
      end

      private

      def capture3(command)
        UnderwareLog.info("SystemCommand: #{command}")
        Open3.capture3(command)
      end

      def handle_error(command, stderr, format_error:)
        stderr = stderr.strip
        error = if format_error
                  "'#{command}' produced error '#{stderr}'"
                else
                  stderr
                end
        raise SystemCommandError, error
      end
    end
  end
end
