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

module Underware
  class Configurator
    module ClassMethods
      def self.included(base)
        base.extend Methods
      end

      module Methods
        def for_domain(alces)
          new(
            alces,
            questions_section: :domain
          )
        end

        def for_group(alces, group_name)
          new(
            alces,
            questions_section: :group,
            name: group_name
          )
        end

        def for_node(alces, node_name)
          new(
            alces,
            questions_section: :node,
            name: node_name
          )
        end

        # Used by the tests to switch readline on and off
        def use_readline
          true
        end
      end
    end
  end
end
