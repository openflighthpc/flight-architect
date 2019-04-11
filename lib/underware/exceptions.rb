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

module Underware
  class UnderwareError < StandardError; end

  # NOTE: Can these be condensed?
  class NoGenderGroupError < UnderwareError; end
  class NodeNotInGendersError < UnderwareError; end

  class SystemCommandError < UnderwareError; end
  class StrictWarningError < UnderwareError; end
  class InvalidInput < UnderwareError; end
  class FileDoesNotExistError < UnderwareError; end
  class DataError < UnderwareError; end
  class UninitializedLocalNode < UnderwareError; end
  class MissingRecordError < UnderwareError; end
  class NoNetworkInterfacesAvailable < UnderwareError; end

  class InvalidGroupName < UnderwareError; end
  class RepeatedGroupError < UnderwareError; end

  class RecursiveConfigDepthExceededError < UnderwareError
    def initialize(msg = 'Input hash may contain infinitely recursive ERB')
      super
    end
  end

  class CombineHashError < UnderwareError
    def initialize(msg = 'Could not combine config or answer hashes')
      super
    end
  end

  class InternalError < UnderwareError; end
  class AnswerJSONSyntax < UnderwareError; end
  class ScopeError < UnderwareError; end
  class ValidationFailure < UnderwareError; end

  class CaughtInterrupt < UnderwareError; end

  class ClusterAttrError < UnderwareError; end

  # XXX, we need think about the future of the DependencyFailure,
  # It maybe completely replaced with Validation::Loader and a file cache.
  # If this is the case Dependency Failure/ InternalError will be replaced
  # with Validation Failure

  # Use this error as the general catch all in Dependencies
  # The dependency can't be checked as the logic doesn't make sense
  # NOTE: We should try and prevent these errors from appearing in production
  class DependencyInternalError < UnderwareError
  end

  # Use this error when the dependency is checked but isn't met
  # NOTE: This is the only dependency error we see in production
  class DependencyFailure < UnderwareError
  end

  class SaverNoData < UnderwareError
    def initialize(msg = 'No data provided to Validation::Saver'); end
  end

  # Alias for Exception to use to indicate we want to catch everything, and to
  # also tell Rubocop to be quiet about this.
  IntentionallyCatchAnyException = Exception
end
