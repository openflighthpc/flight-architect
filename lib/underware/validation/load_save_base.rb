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
