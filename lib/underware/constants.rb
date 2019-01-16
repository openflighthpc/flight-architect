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

require 'underware/hash_mergers/underware_recursive_open_struct'

module Underware
  module Constants
    STORAGE_PATH = '/var/lib/underware'

    # Directory name where shared 'content' templates live.
    CONTENT_DIR_NAME = 'content'

    # XXX For now Underware needs some knowledge of Metalware, so it can
    # provide access to Metalware-specific things in the Underware namespace.
    # See from https://alces.slack.com/archives/CD7GNLP8D/p1540303912000100 for
    # details; long term we should implement some generic way for Metalware and
    # other clients to provide Underware with access to their own data for
    # nodes.
    METALWARE_DATA_PATH = '/var/lib/metalware'
    EVENTS_DIR_PATH = File.join(METALWARE_DATA_PATH, 'events')

    MAXIMUM_RECURSIVE_CONFIG_DEPTH = 10

    CONFIGURE_SECTIONS = [:domain, :group, :node].freeze
    CONFIGURE_INTERNAL_QUESTION_PREFIX = 'underware_internal'

    # This only exists for legacy purposes so we have a constant we can stub to
    # skip validations; ideally we would handle wanting to test things without
    # running validations in a better way.
    SKIP_VALIDATION = false

    LOG_SEVERITY = 'INFO'
  end
end
