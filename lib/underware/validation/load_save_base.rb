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

require 'underware/file_path'
require 'underware/validation/answer'
require 'underware/validation/configure'
require 'underware/data'

module Underware
  module Validation
    class LoadSaveBase
      def domain_answers
        answer(FilePath.domain_answers, :domain)
      end

      def group_answers(name)
        answer(FilePath.group_answers(name), :group)
      end

      def node_answers(name)
        answer(FilePath.node_answers(name), :node)
      end

      def section_answers(section, name = nil)
        case section
        when :domain
          domain_answers
        when :group
          raise InternalError, 'No group name given' if name.nil?
          group_answers(name)
        when :node
          raise InternalError, 'No node name given' if name.nil?
          node_answers(name)
        when :platform
          # Platforms do not have answers, so always just return empty hash
          # (this means nothing different will happen when merging answers,
          # whether `platform` key is passed to `HashMerger#merge` or not).
          {}
        else
          raise InternalError, "Unrecognised question section: #{section}"
        end
      end

      private

      attr_reader :config

      def answer(_absolute_path, _section)
        raise NotImplementedError
      end
    end
  end
end
