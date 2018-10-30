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

require 'underware/constants'
require 'underware/file_path/config_path'

module Underware
  module FilePath
    class << self
      delegate :domain_config,
               :group_config,
               :node_config,
               :local_config,
               to: :config_path

      def configure_file
        File.join(repo, 'configure.yaml')
      end

      def domain_answers
        File.join(answer_files, 'domain.yaml')
      end

      def group_answers(group)
        file_name = "#{group}.yaml"
        File.join(answer_files, 'groups', file_name)
      end

      def node_answers(node)
        file_name = "#{node}.yaml"
        File.join(answer_files, 'nodes', file_name)
      end

      def local_answers
        node_answers('local')
      end

      def answer_files
        File.join(underware_data, 'answers')
      end

      def server_config
        File.join(repo, 'server.yaml')
      end

      def repo
        File.join(underware_data, 'repo')
      end

      def overview
        File.join(repo, 'overview.yaml')
      end

      def plugins_dir
        File.join(underware_data, 'plugins')
      end

      def repo_template_path(template_type, namespace:)
        File.join(
          repo,
          template_type.to_s,
          template_file_name(template_type, namespace: namespace)
        )
      end

      def build_complete(node_namespace)
        event(node_namespace, 'complete')
      end

      # Gives path for a rendered build file, relative to some root directory
      # that all build files will be rendered within (e.g.
      # `/var/lib/metalware/rendered/`).
      def relative_rendered_build_file_path(relative_namespace_files_dir, section, file_name)
        File.join(
          relative_namespace_files_dir,
          section.to_s,
          file_name
        )
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

      def log
        '/var/log/underware'
      end

      def asset_type(type)
        File.join(underware_install, 'data/asset_types', type + '.yaml')
      end

      def asset(*a)
        record(asset_dir, *a)
      end

      def asset_dir
        File.join(underware_data, 'assets')
      end

      def layout(*a)
        record(layout_dir, *a)
      end

      def layout_dir
        File.join(underware_data, 'layouts')
      end

      def asset_cache
        File.join(cache, 'assets.yaml')
      end

      def cached_template(name)
        File.join(cache, 'templates', name)
      end

      def namespace_data_file(name)
        File.join(
          Constants::NAMESPACE_DATA_PATH,
          "#{name}.yaml"
        )
      end

      private

      def record(record_dir, types_dir, name)
        File.join(record_dir, types_dir, name + '.yaml')
      end

      def template_file_name(template_type, namespace:)
        namespace.config.templates&.send(template_type) || 'default'
      end

      def config_path
        @config_path ||= ConfigPath.new(base: repo)
      end
    end
  end
end

Underware::FilePath.define_constant_paths
