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

require 'underware/constants'
require 'underware/data_path'
require 'underware/command_config'

module Underware
  module FilePath
    class << self
      delegate_missing_to :data_path

      def data_path
        DataPath.cluster(CommandConfig.load.current_cluster)
      end

      # TODO: Is this going to in built or configurable per cluster?
      def overview
        File.join(Config.install_path, 'etc', 'overview.yaml')
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
