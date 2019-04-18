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

require 'underware/validation/loader'
require 'underware/validation/saver'
require 'underware/file_path'
require 'underware/configurator/question'
require 'underware/configurator/class_methods'

module Underware
  class Configurator
    include ClassMethods

    def initialize(
      alces,
      questions_section:,
      name: nil
    )
      @alces = alces
      @questions_section = questions_section
      @name = name
    end

    def configure(answers = nil)
      answers ||= ask_questions
      save_answers(answers)
    end

    private

    attr_reader :alces,
                :questions_section,
                :name

    def loader
      @loader ||= Validation::Loader.new
    end

    def saver
      @saver ||= Validation::Saver.new
    end

    def ask_questions
      {}.tap do |answers|
        section_question_tree.each_question do |question|
          identifier = question.identifier
          question.default = default_hash[identifier]
          answers[identifier] = question.ask
        end
      end
    end

    def save_answers(raw_answers)
      answers = reject_non_saved_answers(raw_answers)
      saver.section_answers(answers, questions_section, name)
    end

    def reject_non_saved_answers(answers)
      answers.reject do |identifier, answer|
        higher_level_answers[identifier] == answer
      end
    end

    def higher_level_answers
      @higher_level_answers ||= begin
        case configure_object
        when Namespaces::Domain
          alces.questions.root_defaults
        when Namespaces::Group
          alces.domain.answer
        when Namespaces::Node
          group_for_node(configure_object).answer
        end
      end.to_h # Ensure the un-rendered answer are used
    end

    def group_for_node(node)
      node.group
    end

    def section_question_tree
      alces.questions.section_tree(questions_section)
    end

    def configure_object
      @configure_object ||= begin
        case questions_section
        when :domain
          alces.domain
        when :group
          alces.groups.find_by_name(name) || new_group
        when :node
          alces.nodes.find_by_name(name) || new_node
        else
          raise InternalError, <<-EOF
            Unrecognised question section: #{questions_section}
          EOF
        end
      end
    end

    def default_hash
      @default_hash ||= configure_object&.answer.to_h
    end

    def new_group
      Namespaces::Group.new(alces, name, index: nil)
    end

    def new_node
      Namespaces::NodePrototype.new(alces, name, genders: ['orphan'])
    end
  end
end
