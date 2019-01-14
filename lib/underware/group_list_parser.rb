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
  class GroupListParser
    def self.parse(string)
      string.to_s.split(',').tap do |groups|
        groups.each { |n| error_if_invalid_name(n) }
        error_if_repeated_group(groups)
      end
    end

    private_class_method

    def self.error_if_invalid_name(name)
      return if /\A[[:alnum:]]*\z/.match?(name)
      raise InvalidGroupName, <<~ERROR
        The group name must be alphanumeric: #{name}
      ERROR
    end

    def self.error_if_repeated_group(groups)
      repeats = groups.group_by { |g| g }
                      .select { |_, group_array| group_array.length > 1 }
                      .keys
      return if repeats.empty?
      raise RepeatedGroupError, <<~ERROR.squish
        The following #{repeats.length == 1 ? 'group has' : 'groups have' }
        been specified multiple times: #{repeats.join(',')}
      ERROR
    end
  end
end