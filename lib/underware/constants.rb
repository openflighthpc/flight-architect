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

require 'underware/hash_mergers/underware_recursive_open_struct'

module Underware
  # Constants can be named directly within the module
  APP_NAME = 'underware'

  module Constants
    # Directory name where core templates live
    CONTENT_DIR_NAME = 'core'

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
