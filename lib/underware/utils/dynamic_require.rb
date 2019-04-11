
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
  module Utils
    class DynamicRequire
      class << self
        # Recursively requires all ruby files in the require_directory relative
        # to the calling file's directory
        def relative(require_directory)
          require_files(require_directory).each do |file|
            require file
          end
        end

        private

        def require_files(require_directory)
          # Sorting files to require is needed so that we require files in a
          # deterministic order (globbing by itself is non-deterministic), to
          # prevent issues as described from
          # https://alces.slack.com/archives/C5FL99R89/p1517402592000215.
          Dir[File.join(calling_file_dir, require_directory, '**/*.rb')].sort
        end

        def calling_file_dir
          File.dirname(calling_file_path)
        end

        # Finds the file path of the calling file
        def calling_file_path
          caller.each do |call|
            # Filters line position from caller string
            path = call.match(/\A(?:(?!:).)*/)[0]
            return path unless path == __FILE__
          end
        end
      end
    end
  end
end
