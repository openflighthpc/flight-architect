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

require 'pathname'
require 'zip'

module Underware
  module Commands
    class Export < CommandHelpers::BaseCommand
      def run
        paths = DataPath.cluster(CommandConfig.load.current_cluster)
        Zip::File.open(generate_export_path, Zip::File::CREATE) do |zip|
          Dir.glob(paths.rendered('**/*'))
             .map { |p| Pathname.new(p) }
             .reject(&:directory?)
             .each do |path|
            zip.add(path.relative_path_from(Pathname.new(paths.rendered)), path)
          end
          puts "Exported: #{zip.name}"
        end
      end

      private

      def generate_export_path
        File.expand_path("~/underware-#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.zip")
      end
    end
  end
end
