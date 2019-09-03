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

#
# This file contains ruby configuration that should be constant
#

require 'active_support/core_ext/module/delegation'
require 'flight_config'
require 'underware/data_path'
require 'underware/data_copy'

module Underware
  class Config
    include FlightConfig::Loader

    class << self
      def cache
        @cache ||= self.load
      end
      delegate_missing_to :cache

      def reset
        # The config should always be static
        # :noop:
      end
    end

    def initialize(*_a)
      super
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
      __data__.fetch(:logs_path, default: '/var/log/architect')
    end

    def storage_path
      __data__.fetch(:storage_path, default: '/var/lib/architect')
    end
  end
end
