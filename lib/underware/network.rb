
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

require 'network_interface'

module Underware
  module Network
    class << self
      LOOPBACK = 'lo'

      # Upgrade `activesupport` and swap these, once a version containing
      # https://github.com/rails/rails/pull/31944 has been released (not in a
      # released version of `activesupport` yet, as of 5.2.2):
      private *delegate(:interfaces, to: NetworkInterface)
      # delegate :interfaces, to: NetworkInterface, private: true

      def available_interfaces
        (interfaces - [LOOPBACK]).sort.tap do |available|
          if available.empty?
            raise NoNetworkInterfacesAvailable,
              'No network interfaces available, unable to proceed'
          end
        end
      end
    end
  end
end
