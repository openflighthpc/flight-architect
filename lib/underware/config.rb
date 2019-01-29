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

#
# This file contains ruby configuration that should be constant
#

require 'active_support/core_ext/module/delegation'
require 'underware/config_loader'
require 'underware/data_path'
require 'underware/data_copy'

module Underware
  class InternalConfig
    include ConfigLoader

    def initialize
      __data__.env_prefix = APP_NAME.dup
      __data__.set_from_env(:debug)
    end

    def path
      File.join(install_path, 'etc/config.yaml')
    end

    def debug
      __data__.fetch(:debug)
    end

    def install_path
      File.absolute_path(File.join(File.dirname(__FILE__), '../..'))
    end

    def log_path
      __data__.fetch(:logs_path, default: '/var/log/underware')
    end

    def storage_path
      __data__.fetch(:storage_path, default: '/var/lib/underware')
    end
  end

  class Config
    include ConfigLoader

    class << self
      def cache
        @cache ||= self.load
      end
      delegate_missing_to :cache

      def update(*a)
        reset
        super
      end

      def reset
        @cache = nil
      end
    end

    delegate_missing_to :internal_config

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
