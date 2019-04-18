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

require 'underware/network'
require 'underware/system_command'

# XXX All the URLs here have paths under `/metalware`, and only make sense/have
# any chance of resolving when Metalware (and the web server set up by this) is
# also installed; they must live here though as they need to be accessed via
# the Underware namespaces. Long term there might be a better way for this to
# be setup; maybe Underware should detect Metalware is installed and warn/error
# if these values are accessed when it is not?

module Underware
  module DeploymentServer
    class << self
      delegate :build_interface, to: :alces

      def ip
        ip_on_interface(build_interface)
      end

      def system_file_url(system_file)
        url "system/#{system_file}"
      end

      def kickstart_url(node_name)
        if node_name
          path = File.join('kickstart', node_name)
          url path
        end
      end

      def build_complete_url(node_name)
        url "exec/kscomplete.php?name=#{node_name}" if node_name
      end

      private

      def url(url_path)
        full_path = File.join('metalware', url_path)
        URI.join("http://#{ip}", full_path).to_s
      end

      def ip_on_interface(interface)
        command = "#{determine_hostip_script} #{interface}"
        SystemCommand.run(command).chomp
      end

      def determine_hostip_script
        File.join(Config.install_path, 'libexec/determine-hostip')
      end

      def alces
        Namespaces::Alces.new
      end
    end
  end
end
