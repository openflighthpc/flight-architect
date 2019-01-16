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
