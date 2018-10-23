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

require 'underware/hash_mergers/underware_recursive_open_struct'

module Underware
  module Constants
    UNDERWARE_INSTALL_PATH =
      File.absolute_path(File.join(File.dirname(__FILE__), '../..'))

    UNDERWARE_CONFIGS_PATH = File.join(UNDERWARE_INSTALL_PATH, 'etc')
    DEFAULT_CONFIG_PATH = File.join(UNDERWARE_CONFIGS_PATH, 'config.yaml')

    UNDERWARE_DATA_PATH = '/var/lib/underware'
    CACHE_PATH = File.join(UNDERWARE_DATA_PATH, 'cache')
    NAMESPACE_DATA_PATH = File.join(UNDERWARE_DATA_PATH, 'data')
    HUNTER_PATH = File.join(NAMESPACE_DATA_PATH, 'hunter.yaml')
    GROUP_CACHE_PATH = File.join(CACHE_PATH, 'groups.yaml')
    RENDERED_DIR_PATH = File.join(UNDERWARE_DATA_PATH, 'rendered')
    PLUGINS_CACHE_PATH = File.join(CACHE_PATH, 'plugins.yaml')

    # XXX For now Underware needs some knowledge of Metalware, so it can
    # provide access to Metalware-specific things in the Underware namespace.
    # See from https://alces.slack.com/archives/CD7GNLP8D/p1540303912000100 for
    # details; long term we should implement some generic way for Metalware and
    # other clients to provide Underware with access to their own data for
    # nodes.
    METALWARE_DATA_PATH = 'var/lib/metalware'
    EVENTS_DIR_PATH = File.join(METALWARE_DATA_PATH, 'events')

    MAXIMUM_RECURSIVE_CONFIG_DEPTH = 10

    NODEATTR_COMMAND = 'nodeattr'

    GENDERS_PATH = File.join(UNDERWARE_DATA_PATH, 'rendered/system/genders')

    DRY_VALIDATION_ERRORS_PATH = File.join(UNDERWARE_INSTALL_PATH,
                                           'lib/underware/validation',
                                           'errors.yaml')

    CONFIGURE_SECTIONS = [:domain, :group, :node, :local].freeze
    CONFIGURE_INTERNAL_QUESTION_PREFIX = 'underware_internal'

    HASH_MERGER_DATA_STRUCTURE =
      Underware::HashMergers::UnderwareRecursiveOpenStruct

    BUILD_POLL_SLEEP = 10

    # This only exists for legacy purposes so we have a constant we can stub to
    # skip validations; ideally we would handle wanting to test things without
    # running validations in a better way.
    SKIP_VALIDATION = false

    LOG_SEVERITY = 'INFO'
  end
end
