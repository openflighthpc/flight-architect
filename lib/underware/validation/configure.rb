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

require 'underware/exceptions'
require 'underware/file_path'
require 'underware/data'
require 'dry-validation'
require 'underware/constants'
require 'underware/question_tree'
require 'stringio'

require 'underware/validation/configure/schemas'

module Underware
  module Validation
    class Configure
      SUPPORTED_TYPES = [
        'boolean',
        'integer',
        'interface',
        'password',
        'string',
      ].freeze

      def self.type_check(type, value)
        case type
        when 'string', 'password', nil
          value.is_a?(String)
        when 'integer'
          value.is_a?(Integer)
        when 'boolean'
          [true, false].include?(value)
        when 'interface'
          Network.available_interfaces.include?(value)
        else
          false
        end
      end

      def initialize(questions_hash)
        @questions_hash = questions_hash.freeze
        raise_error_if_validation_failed
      end

      def tree
        @tree ||= begin
          root_hash = {
            pass: true,
            result: TopLevelSchema.call(data: questions_hash),
          }
          QuestionTree.new('ROOT', root_hash).tap do |root|
            add_children(root, root) do
              Constants::CONFIGURE_SECTIONS.map do |section|
                make_section_node(root, section)
              end
            end
            # Make the content OpenStructs
            root.each { |node| node.content = OpenStruct.new(node.content) }
          end
        end
      end

      private

      attr_reader :questions_hash
      attr_accessor :failed_validation

      def raise_error_if_validation_failed
        return if success?
        prune_successful_leaves
        io = StringIO.new
        print_error_node(io)
        tree.print_tree(0, nil, print_error_node(io))
        io.rewind
        raise ValidationFailure, io.read
      end

      def print_error_node(io)
        lambda do |node, prefix|
          io.puts "#{prefix} #{node.name}"
          result = node.content[:result]
          io.puts result.errors.to_s unless result.success?
        end
      end

      def success?
        tree.content[:pass]
      end

      def make_section_node(root, section)
        question_data = questions_hash[section] || []
        data = {
          section: section,
          result: DependantSchema.call(dependent: question_data),
        }
        node_s = QuestionTree.new(section, data)
        add_children(root, node_s) do
          question_data.map { |q| make_question_node(root, q) }
        end
      end

      def make_question_node(root, **question)
        result_h = { result: QuestionSchema.call(question: question) }
        data = (question.is_a?(Hash) ? question.merge(result_h) : result_h)
        node_q = QuestionTree.new(data[:identifier].to_s, data)
        add_children(root, node_q) do
          question[:dependent]&.map do |sub_question|
            make_question_node(root, **sub_question)
          end
        end
      end

      def add_children(root, parent)
        if parent.content[:result].success?
          yield&.each { |child| parent << child }
        else
          root.content[:pass] = false
        end
        parent
      end

      def prune_successful_leaves
        # Postorder sort starts at the leaves and works its way in
        tree.postordered_each do |node|
          node.remove_from_parent! if begin
            if node.has_children? # Only remove leaves
              false
            elsif node.content[:result].success? # Remove successful nodes
              true
            else
              false
            end
          end
        end
      end
    end
  end
end
