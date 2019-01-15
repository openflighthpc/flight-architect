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

require 'tty/config'

module Underware
  module Patches
    module TTYConfig
      ##
      # Redefine TTY::Config to use the custom YAML parser
      #
      def self.included(base)
        base.const_set('YAML', PatchedYAML)
      end

      module PatchedYAML
        class << self
          delegate_missing_to Psych
        end

        ##
        # Overload `safe_load` to always allow aliases. It obeys the other
        # directives however
        #
        def self.safe_load(yaml,
                           whitelist_classes = [],
                           whitelist_symbols = [],
                           _aliases = false,
                           filename = nil)
          super(yaml, whitelist_classes, whitelist_symbols, true, filename)
        end
      end
    end

    TTY::Config.include TTYConfig
  end
end
