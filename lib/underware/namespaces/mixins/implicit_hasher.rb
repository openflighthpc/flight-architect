
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
  module Namespaces
    module Mixins
      module ImplicitHasher
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
          (public_methods - Object.public_methods - [:to_h, :initialize])
            .select { |n| method(n).arity == 0 }
            .reduce({}) do |memo, method|
            value = __send__(method)
            hashed_value = ImplicitHasher.convert_to_hash(value)
            memo.merge(method => hashed_value)
          end
        end
      end
    end
  end
end
