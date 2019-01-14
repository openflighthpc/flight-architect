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
  # Class to generate reused `dependency_hash`s, for use by `Dependency` object
  # to enforce command dependencies.
  # XXX Consider moving generating of more `dependency_hash`s here.
  class DependencySpecifications
    def initialize(alces)
      @alces = alces
    end

    def for_node_in_configured_group(name)
      group = find_node(name).group
      {
        configure: ['domain.yaml', "groups/#{group.name}.yaml"],
        optional: {
          configure: ["nodes/#{name}.yaml"],
        },
      }
    end

    private

    attr_reader :alces

    def find_node(name)
      node = alces.nodes.find_by_name(name)
      raise NodeNotInGendersError, "Could not find node: #{name}" unless node
      node
    end
  end
end
