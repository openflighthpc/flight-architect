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

require 'underware/constants'
require 'underware/data_path'
require 'underware/config'

module Underware
  module FilePath
    class << self
      delegate_missing_to :data_path

      def data_path
        DataPath.cluster(Config.current_cluster)
      end

      # TODO: Is this going to in built or configurable per cluster?
      def overview
        File.join(DataPath.new.base, 'overview.yaml')
      end

      # NOTE: Deprecated! This method should be removed completely
      def templates_dir
        data_path.template
      end

      # NOTE: Deprecated! This method should be removed completely
      def answers_dir
        data_path.join('answers').tap { |p| FileUtils.mkdir_p(p) }
      end

      # NOTE: Deprecated! This method should be removed completely
      def config_dir
        data_path.join('etc/configs').tap { |p| FileUtils.mkdir_p(p) }
      end

      # NOTE: Deprecated! This method should be removed completely
      def platform_configs_dir
        File.join(config_dir, 'platforms')
      end

      # NOTE: Deprecated! This method should be removed completely
      def plugins_dir
        data_path.plugin
      end

      # NOTE: Deprecated! This is a specific method that should be extracted
      # to a dedicated class
      def plugin_cache
        data_path.join('plugins.yaml')
      end

      # NOTE: Deprecated! This is set directly from the Config
      def logs_dir
        Config.log_path
      end

      def dry_validation_errors
        File.join(Config.install_path, 'lib/underware/validation/errors.yaml')
      end

      # NOTE: Deprecated! This method should be removed completely
      def namespace_data_file(name)
        data_path.data_config(name)
      end
    end
  end
end
