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
require 'underware/file_path/config_path'
require 'underware/data_path'

module Underware
  module FilePath
    class << self
      delegate :domain_config,
               :group_config,
               :node_config,
               :config_dir,
               to: :config_path

      delegate_missing_to :data_path_cache

      def data_path_cache
        @data_path_cache ||= DataPath.new(cluster: Config.current_cluster)
      end

      # NOTE: This method is not going to be migrated onto DataPath
      # It has been replaced by the more general `template` method
      def templates_dir
        data_path_cache.template
      end

      def domain_answers
        File.join(answers_dir, 'domain.yaml')
      end

      def group_answers(group)
        file_name = "#{group}.yaml"
        File.join(answers_dir, 'groups', file_name)
      end

      def node_answers(node)
        file_name = "#{node}.yaml"
        File.join(answers_dir, 'nodes', file_name)
      end

      def answers_dir
        File.join(underware_storage, 'answers')
      end

      # TODO: Is this going to in built or configurable per cluster?
      def overview
        File.join(internal_data_dir, 'overview.yaml')
      end

      def plugins_dir
        File.join(underware_storage, 'plugins')
      end

      def build_complete(node_namespace)
        event(node_namespace, 'complete')
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

      def event(node_namespace, event = '')
        File.join(events_dir, node_namespace.name, event)
      end

      def logs_dir
        '/var/log/underware'
      end

      def asset_type(type)
        File.join(underware_install, 'data/asset_types', type + '.yaml')
      end

      # NOTE: This method has been deprecated and will not be ported to
      # DataPath
      def assets_dir
        data_path_cache.asset
      end

      # NOTE: This method has been deprecated and will not be ported to
      # DataPath
      def layouts_dir
        data_path_cache.layout
      end

      def asset_cache
        File.join(cache, 'assets.yaml')
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

      def platform_config(platform)
        File.join(platform_configs_dir, "#{platform}.yaml")
      end

      def platform_configs_dir
        File.join(config_dir, 'platforms')
      end

      def init_data(relative_path)
        File.join(internal_data_dir, 'init', relative_path)
      end

      private

      def record(record_dir, types_dir, name)
        File.join(record_dir, types_dir, name + '.yaml')
      end

      def config_path
        ConfigPath.new(base: internal_data_dir)
      end
    end
  end
end

Underware::FilePath.define_constant_paths
