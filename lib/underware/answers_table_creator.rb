
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

require 'terminal-table'
require 'underware/validation/loader'

module Underware
  class AnswersTableCreator
    def initialize(alces)
      @alces = alces
    end

    def domain_table
      answers_table
    end

    def group_table(group_name)
      answers_table(group_name: group_name)
    end

    def node_table(node_name)
      group_name = alces.nodes.find_by_name(node_name).group.name
      answers_table(group_name: group_name, node_name: node_name)
    end

    private

    attr_reader :alces

    def answers_table(group_name: nil, node_name: nil)
      Terminal::Table.new(
        headings: headings(group_name: group_name, node_name: node_name),
        rows: rows(group_name: group_name, node_name: node_name)
      )
    end

    def headings(group_name:, node_name:)
      [
        'Question',
        'Domain',
        group_name ? "Group: #{group_name}" : nil,
        node_name ?  "Node: #{node_name}" : nil,
      ].reject(&:nil?)
    end

    def rows(group_name:, node_name:)
      question_identifiers.map do |identifier|
        [
          identifier,
          domain_answer(question: identifier),
          group_answer(question: identifier, group_name: group_name),
          node_answer(question: identifier, node_name: node_name),
        ].reject(&:nil?)
      end
    end

    def question_identifiers
      @question_identifiers ||= Underware::Validation::Loader.new
                                                             .question_tree
                                                             .identifiers
                                                             .sort
                                                             .uniq
    end

    def domain_answer(question:)
      format_answer(question: question, namespace: alces.domain)
    end

    def group_answer(question:, group_name:)
      return nil unless group_name
      format_answer(
        question: question,
        namespace: alces.groups.find_by_name(group_name)
      )
    end

    def node_answer(question:, node_name:)
      return nil unless node_name
      format_answer(
        question: question,
        namespace: alces.nodes.find_by_name(node_name)
      )
    end

    def format_answer(question:, namespace:)
      # `inspect` the answer to get it with an indication of its type, so e.g.
      # strings are wrapped in quotes, and can distinguish from integers etc.
      namespace.answer.to_h[question.to_sym].inspect
    end
  end
end
