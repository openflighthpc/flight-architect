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
require 'underware/validation/loader'
require 'underware/validation/load_save_base'
require 'underware/data'
require 'underware/plugins'

module Underware
  module Validation
    class Loader < LoadSaveBase
      def question_tree
        # XXX Extract object for loading configure data?
        @questions ||=
          Validation::Configure.new(combined_configure_data).tree
      end

      def section_tree(section)
        question_tree.section_tree(section)
      end

      def group_cache
        Data.load(FilePath.group_cache)
      end

      private

      def answer(absolute_path, section)
        yaml = Data.load(absolute_path)
        validator = Validation::Answer.new(yaml,
                                           answer_section: section,
                                           question_tree: question_tree)
        validator.data
      end

      def combined_configure_data
        Constants::CONFIGURE_SECTIONS.map do |section|
          [section, all_questions_for_section(section)]
        end.to_h
      end

      def all_questions_for_section(section)
        [
          core_configure_questions,
          *plugin_configure_questions,
        ].flat_map do |question_group|
          question_group[section]
        end
      end

      def core_configure_questions
        @core_configure_questions ||= Data.load(FilePath.configure)
      end

      def plugin_configure_questions
        @plugin_configure_questions ||=
          Plugins.activated.map(&:configure_questions)
      end
    end
  end
end
