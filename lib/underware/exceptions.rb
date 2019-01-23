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
