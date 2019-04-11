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
  module Plugins
    ConfigureQuestionsBuilder = Struct.new(:plugin) do
      private_class_method :new

      def self.build(plugin)
        new(plugin).build
      end

      def build
        Constants::CONFIGURE_SECTIONS.map do |section|
          [section, question_hash_for_section(section)]
        end.to_h
      end

      private

      def question_hash_for_section(section)
        {
          identifier: plugin.enabled_question_identifier,
          question: "Should '#{plugin.name}' plugin be enabled for #{section}?",
          type: 'boolean',
          dependent: questions_for_section(section),
        }
      end

      def questions_for_section(section)
        question_tree[section].map { |q| namespace_question_hash(q) }
      end

      def question_tree
        @question_tree ||= default_configure_data.merge(
          Data.load(configure_file_path)
        )
      end

      def default_configure_data
        Constants::CONFIGURE_SECTIONS.map do |section|
          [section, []]
        end.to_h
      end

      def configure_file_path
        File.join(plugin.path, 'configure.yaml')
      end

      def namespace_question_hash(question_hash)
        # Prepend plugin name to question text, as well as recursively to all
        # dependent questions, so source of plugin questions is clear when
        # configuring.
        question_hash.map do |k, v|
          new_value = case k
                      when :question
                        "#{plugin_identifier} #{v}"
                      when :dependent
                        v.map { |q| namespace_question_hash(q) }
                      else
                        v
                      end
          [k, new_value]
        end.to_h
      end

      def plugin_identifier
        "[#{plugin.name}]"
      end
    end
  end
end
