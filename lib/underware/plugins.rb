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

require 'underware/plugins/configure_questions_builder'
require 'underware/plugins/plugin'

module Underware
  module Plugins
    class << self
      def all
        plugin_directories.map do |dir|
          Plugin.new(dir)
        end
      end

      def activated
        all.select(&:activated?)
      end

      def activated?(plugin_name)
        !deactivated_plugin_names.include?(plugin_name)
      end

      def activate!(plugin_name)
        validate_plugin_exists!(plugin_name)
        return if activated?(plugin_name)

        new_deactivated_plugins = deactivated_plugin_names.reject do |name|
          name == plugin_name
        end
        update_deactivated_plugins!(new_deactivated_plugins)
      end

      def deactivate!(plugin_name)
        validate_plugin_exists!(plugin_name)

        new_deactivated_plugins = deactivated_plugin_names + [plugin_name]
        update_deactivated_plugins!(new_deactivated_plugins)
      end

      def enabled_question_identifier(plugin_name)
        [
          Constants::CONFIGURE_INTERNAL_QUESTION_PREFIX,
          'plugin_enabled',
          plugin_name,
        ].join('--')
      end

      private

      def validate_plugin_exists!(plugin_name)
        return if exists?(plugin_name)
        raise UnderwareError, "Unknown plugin: #{plugin_name}"
      end

      def update_deactivated_plugins!(new_deactivated_plugins)
        new_cache = cache.merge(deactivated: new_deactivated_plugins)
        Data.dump(FilePath.plugin_cache, new_cache)
      end

      def exists?(plugin_name)
        all_plugin_names.include?(plugin_name)
      end

      def deactivated_plugin_names
        cache[:deactivated] || []
      end

      def all_plugin_names
        all.map(&:name)
      end

      def plugin_directories
        return [] unless plugins_dir.exist?
        plugins_dir.children.select(&:directory?)
      end

      def plugins_dir
        Pathname.new(FilePath.plugins_dir)
      end

      def cache
        Data.load(FilePath.plugin_cache)
      end
    end
  end
end
