
# frozen_string_literal: true

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
