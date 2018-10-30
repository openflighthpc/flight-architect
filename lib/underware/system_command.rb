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
