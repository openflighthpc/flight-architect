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

require 'commander'
require 'colorize'

# Require just parts of ActiveSupport that we use throughout Underware - do not
# just `require 'active_support/all'` as this can cause surprising issues due
# to unexpected monkey-patching, e.g.
# https://github.com/alces-software/underware/issues/40.
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/deep_dup'
require 'active_support/core_ext/string/strip'
require 'active_support/inflector'
require 'active_support/string_inquirer'

require 'underware/config'
require 'underware/cli_helper/parser'
require 'underware/data'

module Underware
  class Cli
    include Commander::Methods

    def run
      program :name, 'architect'
      program :version, VERSION
      program :description, <<-EOF.squish
        Tool for managing standard config hierarchy and template rendering
        under-lying Alces clusters and other Alces tools
      EOF

      # Suppress the `--trace` on all outputs. It is now a semi-hidden feature
      suppress_trace_class Exception

      CliHelper::Parser.new(self).parse_commands

      run!
    end

    def run!
      ARGV.push '--help' if ARGV.empty?
      super
    end
  end
end
