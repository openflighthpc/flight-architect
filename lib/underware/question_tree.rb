
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

require 'rubytree'
require 'ostruct'

module Underware
  class QuestionTree < Tree::TreeNode
    attr_accessor :answer

    delegate :choices, :optional, :type, to: :content_struct

    BASE_TRAVERSALS = [
      :each,
      :breadth_each,
      :postordered_each,
      :preordered_each,
    ].freeze

    BASE_TRAVERSALS.each do |base_method|
      define_method(:"filtered_#{base_method}") do |&block|
        questions = public_send(base_method).find_all(&:question?)
        block ? questions.each { |q| block.call(q) } : questions.to_enum
      end
    end

    def each_question
      filtered_each.with_index do |question, index|
        next unless question.should_ask?
        progress_indicator = "(#{index + 1}/#{questions_length})"
        yield create_question(question, progress_indicator)
      end
    end

    def should_ask?
      top_level_question = !parent.question?
      parent_is_truthy = parent.answer
      top_level_question || parent_is_truthy
    end

    def questions_length
      @questions_length ||= filtered_each.to_a.length
    end

    def question?
      !!identifier
    end

    def identifiers
      filtered_each.map(&:identifier)
    end

    def identifier
      content_struct.identifier&.to_sym
    end

    def text
      content_struct.question
    end

    def yaml_default
      content_struct.default
    end

    def section_tree(section)
      root.children.find { |c| c.name == section }
    end

    def root_defaults
      @root_defaults ||= begin
        Constants::CONFIGURE_SECTIONS.reverse.reduce({}) do |memo, section|
          memo.merge(section_default_hash(section))
        end
      end
    end

    def flatten
      filtered_each.reduce({}) do |memo, node|
        memo.merge(node.identifier => node)
      end
    end

    private

    def section_default_hash(section)
      section_tree(section).filtered_each.reduce({}) do |memo, question|
        memo.merge(question.identifier => question.yaml_default)
      end
    end

    # TODO: Stop wrapping the content in the validator, that should really
    # be done within the QuestionTree object. It doesn't hurt, as you can't
    # double wrap and OpenStruct, it just isn't required
    def content_struct
      OpenStruct.new(content)
    end

    def create_question(question, progress_indicator)
      Configurator::Question.new(question, progress_indicator)
    end
  end
end
