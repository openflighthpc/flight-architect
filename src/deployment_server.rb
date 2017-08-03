# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Metalware.
#
# Alces Metalware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Metalware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Metalware, please visit:
# https://github.com/alces-software/metalware
#==============================================================================

module Metalware
  module DeploymentServer
    class << self
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

      def build_file_url(node_name, namespace, file_name)
        path = File.join(node_name, namespace.to_s, file_name)
        url path
      end

      private

      def url(url_path)
        full_path = File.join('metalware', url_path)
        URI.join("http://#{ip}", full_path).to_s
      end

      def build_interface
        # Default to 'eth0' if `build_interface` is not set yet. In practise
        # this _should_ only occur prior to first render of server config, but
        # this is needed so a valid interface is used when rendering the server
        # config itself (the template shouldn't normally depend on values
        # dependent on the `build_interface`, but if it's unspecified the
        # `alces` namespace will fail to be created).
        server_config[:build_interface] || 'eth0'
      end

      def server_config
        Data.load(Constants::SERVER_CONFIG_PATH)
      end

      def ip_on_interface(interface)
        command = "#{determine_hostip_script} #{interface}"
        SystemCommand.run(command).chomp
      end

      def determine_hostip_script
        File.join(
          Constants::METALWARE_INSTALL_PATH,
          'libexec/determine-hostip'
        )
      end
    end
  end
end
