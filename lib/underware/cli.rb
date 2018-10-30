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

require 'bundler/setup'
require 'commander'
require 'underware/config'
require 'colorize'

require 'underware/cli_helper/parser'
require 'underware/data'

module Underware
  class Cli
    include Commander::Methods

    def run
      program :name, 'underware'
      program :version, VERSION
      program :description, <<-EOF.squish
        Tool for managing standard config hierarchy and template rendering
        under-lying Alces clusters and other Alces tools
      EOF

      suppress_trace_class UserUnderwareError

      CliHelper::Parser.new(self).parse_commands

      run!
    end

    def run!
      ARGV.push '--help' if ARGV.empty?
      super
    end
  end
end
