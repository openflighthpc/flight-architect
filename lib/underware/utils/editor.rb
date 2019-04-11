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

require 'underware/utils'
require 'fileutils'
require 'tempfile'
require 'highline'

module Underware
  module Utils
    class Editor
      DEFAULT_EDITOR = 'vi'

      class << self
        def open(file)
          SystemCommand.no_capture("#{editor} #{file}")
        end

        def editor
          ENV['VISUAL'] || ENV['EDITOR'] || DEFAULT_EDITOR
        end

        def open_copy(source, destination, &validator)
          Utils.copy_via_temp_file(source, destination) do |path|
            open(path)
            raise_if_validation_fails(path, &validator) if validator
          end
        end

        private

        def raise_if_validation_fails(path, &validator)
          return if yield path
          prompt_user
          open(path)
          raise_if_validation_fails(path, &validator) if validator
        end

        def prompt_user
          cli = HighLine.new
          if cli.agree(<<-EOF.squish
                The file is invalid and will be discarded,
                would you like to reopen? (y/n)
              EOF
                      )
          else
            raise ValidationFailure, <<-EOF.squish
              Failed to edit file, changes have been discarded
            EOF
          end
        end
      end
    end
  end
end
