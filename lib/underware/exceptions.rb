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
  # UnderwareError is the base error class to distinguish the custom errors
  # from the built ins/ other libraries. The UserUnderwareError is a subset
  # of the errors that result from a user action (as opposed to underware
  # failing). The user errors suppress the `--trace` prompt, which should
  # make it clearer that it isn't an internal underware error.
  class UnderwareError < StandardError; end
  class UserUnderwareError < UnderwareError; end

  # NOTE: Can these be condensed?
  class NoGenderGroupError < UserUnderwareError; end
  class NodeNotInGendersError < UserUnderwareError; end

  class SystemCommandError < UserUnderwareError; end
  class StrictWarningError < UserUnderwareError; end
  class InvalidInput < UserUnderwareError; end
  class FileDoesNotExistError < UserUnderwareError; end
  class DataError < UserUnderwareError; end
  class UninitializedLocalNode < UserUnderwareError; end
  class MissingRecordError < UserUnderwareError; end
  class NoNetworkInterfacesAvailable < UserUnderwareError; end

  class RecursiveConfigDepthExceededError < UserUnderwareError
    def initialize(msg = 'Input hash may contain infinitely recursive ERB')
      super
    end
  end

  class CombineHashError < UserUnderwareError
    def initialize(msg = 'Could not combine config or answer hashes')
      super
    end
  end

  class InternalError < UnderwareError; end
  class AnswerJSONSyntax < UnderwareError; end
  class ScopeError < UnderwareError; end
  class ValidationFailure < UserUnderwareError; end

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
  class DependencyFailure < UserUnderwareError
  end

  class SaverNoData < UnderwareError
    def initialize(msg = 'No data provided to Validation::Saver'); end
  end

  # Alias for Exception to use to indicate we want to catch everything, and to
  # also tell Rubocop to be quiet about this.
  IntentionallyCatchAnyException = Exception

  class ExistingNodeError < UserUnderwareError
  end

  class ExistingGroupError < UserUnderwareError
  end
end
