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

# Make 'chassis' both the singular and plural
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'chassis', 'chassis'
end

module Underware
  class Config
    include ConfigLoader

    class << self
      def cache
        @cache ||= self.load
      end
      delegate_missing_to :cache
    end

    def path
      File.join(install_path, 'etc/config.yaml')
    end

    def current_cluster
      __data__.fetch(:current_cluster, default: 'default')
    end

    def current_cluster=(cluster_identifier)
      __data__.set(:current_cluster, value: cluster_identifier)
    end

    def install_path
      File.absolute_path(File.join(File.dirname(__FILE__), '../..'))
    end

    # XXX For now Underware needs some knowledge of Metalware, so it can
    # provide access to Metalware-specific things in the Underware namespace.
    # See from https://alces.slack.com/archives/CD7GNLP8D/p1540303912000100 for
    # details; long term we should implement some generic way for Metalware and
    # other clients to provide Underware with access to their own data for
    # nodes.
    def events_dir
      '/var/lib/metalware/events'
    end

    def storage_path
      '/var/lib/underware'
    end
  end
end
