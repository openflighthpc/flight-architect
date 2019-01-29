# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2019 Stephen F. Norledge and Alces Software Ltd.
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

module Underware
  class CommandConfig
    include ConfigLoader

    delegate_missing_to Config

    def path
      File.join(storage_path, 'etc/config.yaml')
    end

    def current_cluster
      __data__.fetch(:current_cluster) do
        'default'.tap do |default|
          next if Dir.exist?(DataPath.cluster(default).base)
          DataCopy.overlay_to_cluster(nil, default).all
        end
      end
    end

    def current_cluster=(cluster_identifier)
      __data__.set(:current_cluster, value: cluster_identifier)
    end

    private

    def internal_config
      @internal_config ||= InternalConfig.load
    end
  end
end
