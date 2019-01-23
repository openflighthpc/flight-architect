
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
  module Namespaces
    module Mixins
      module WhiteListHasher
        def self.convert_to_hash(obj)
          if obj.is_a?(Array)
            obj.map { |o| convert_to_hash(o) }
          elsif obj.respond_to?(:to_h) && !obj.is_a?(self)
            obj.to_h
          else
            obj
          end
        end

        def to_h
          (public_methods - Object.public_methods - [:to_h])
            .select { |n| method(n).arity == 0 }
            .reduce({}) do |memo, method|
            value = __send__(method)
            hashed_value = WhiteListHasher.convert_to_hash(value)
            memo.merge(method => hashed_value)
          end
        end
      end
    end
  end
end
