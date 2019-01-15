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
      delegate_missing_to :data_path_cache

      def data_path_cache
        @data_path_cache ||= DataPath.new(cluster: Config.current_cluster)
      end

      # TODO: Should the asset be configurable on a cluster by cluster basis
      def asset_type(type)
        DataPath.new.relative('asset_types', type + '.yaml')
      end

      # TODO: Is this going to in built or configurable per cluster?
      def overview
        File.join(internal_data_dir, 'overview.yaml')
      end

      # TODO: Does this need to be ported? It is more metalware related code
      def event(node_namespace, event = '')
        File.join(events_dir, node_namespace.name, event)
      end

      # TODO: As above
      def build_complete(node_namespace)
        event(node_namespace, 'complete')
      end

      # NOTE: Deprecated! This method should be removed completely
      def templates_dir
        data_path_cache.template
      end

      # NOTE: Deprecated! This method should be removed completely
      def answers_dir
        data_path_cache.relative('answers').tap { |p| FileUtils.mkdir_p(p) }
      end

      # NOTE: Deprecated! This method should be removed completely
      def config_dir
        data_path_cache.relative('configs').tap { |p| FileUtils.mkdir_p(p) }
      end

      # NOTE: Deprecated! This method should be removed completely
      def platform_configs_dir
        File.join(config_dir, 'platforms')
      end

      # NOTE: Deprecated! This method should be removed completely
      def plugins_dir
        data_path_cache.plugin
      end

      def define_constant_paths
        Constants.constants
                 .map(& :to_s)
                 .select { |const| /\A.+_PATH\Z/.match?(const) }
                 .each do |const|
                   method_name = :"#{const.chomp('_PATH').downcase}"
                   define_singleton_method method_name do
                     Constants.const_get(const)
                   end
                 end
      end

      def logs_dir
        '/var/log/underware'
      end

      # NOTE: Deprecated! This method should be removed completely
      def assets_dir
        data_path_cache.asset
      end

      # NOTE: Deprecated! This method should be removed completely
      def layouts_dir
        data_path_cache.layout
      end

      # NOTE: Deprecated! This is a specific method that should be extracted
      # to a dedicated class
      def asset_cache
        data_path_cache.relative('assets-cache.yaml')
      end

      def namespace_data_file(name)
        File.join(
          Constants::NAMESPACE_DATA_PATH,
          "#{name}.yaml"
        )
      end

      def internal_data_dir
        File.join(underware_install, 'data')
      end

      def init_data(relative_path)
        File.join(internal_data_dir, 'init', relative_path)
      end

      private

      def record(record_dir, types_dir, name)
        File.join(record_dir, types_dir, name + '.yaml')
      end
    end
  end
end

Underware::FilePath.define_constant_paths
