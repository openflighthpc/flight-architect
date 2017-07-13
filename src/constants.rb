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
  module Constants
    METALWARE_INSTALL_PATH = File.absolute_path(File.join(File.dirname(__FILE__), '..'))

    METALWARE_CONFIGS_PATH = File.join(METALWARE_INSTALL_PATH, 'etc')
    DEFAULT_CONFIG_PATH = File.join(METALWARE_CONFIGS_PATH, 'config.yaml')

    METALWARE_DATA_PATH = '/var/lib/metalware'
    CACHE_PATH = File.join(METALWARE_DATA_PATH, 'cache')
    HUNTER_PATH = File.join(CACHE_PATH, 'hunter.yaml')
    GROUPS_CACHE_PATH = File.join(CACHE_PATH, 'groups.yaml')

    MAXIMUM_RECURSIVE_CONFIG_DEPTH = 10

    NODEATTR_COMMAND = 'nodeattr'

    HOSTS_PATH = '/etc/hosts'
  end
end
