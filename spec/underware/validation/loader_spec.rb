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

RSpec.describe Underware::Validation::Loader do
  describe '#question_tree' do
    subject { described_class.new }

    let(:configure_sections) do
      Underware::Constants::CONFIGURE_SECTIONS
    end

    let(:configure_questions_hash) do
      configure_sections.map do |section|
        [
          section, [{
            identifier: "#{section}_identifier",
            question: "#{section}_question",
          }]
        ]
      end.to_h
    end

    let(:example_plugin_configure_questions_hash) do
      configure_sections.map do |section|
        dependent_question = {
          identifier: "example_plugin_#{section}_dependent_identifier",
          question: "example_plugin_#{section}_dependent_question",
        }
        top_level_question = {
          identifier: "example_plugin_#{section}_identifier",
          question: "example_plugin_#{section}_question",
          dependent: [dependent_question],
        }
        [section, [top_level_question]]
      end.to_h
    end

    let(:example_plugin_dir) do
      File.join(Underware::FilePath.plugins_dir, 'example')
    end

    let(:sections_to_loaded_questions) do
      configure_sections.map do |section|
        [section, subject.question_tree[section].children]
      end.to_h
    end

    RSpec.shared_examples 'loads_core_configure_questions' do |section|
      it 'loads configure.yaml questions' do
        questions = sections_to_loaded_questions[section]
        question_identifiers = questions.map { |q| q.content.identifier }
        expect(question_identifiers).to include "#{section}_identifier"
      end
    end

    RSpec.shared_examples 'includes_generated_plugin_enabled_question' do |sect|
      it 'includes generated plugin enabled question' do
        question_content = plugin_enabled_question.content

        expect(question_content.question)
          .to eq "Should 'example' plugin be enabled for #{sect}?"
        expect(question_content.type).to eq 'boolean'
      end
    end

    before do
      fs = Underware::Data
      fs.dump(Underware::FilePath.configure, configure_questions_hash)

      # Create example plugin.
      FileUtils.mkdir_p example_plugin_dir
      example_plugin_configure_file =
        File.join(example_plugin_dir, 'configure.yaml')
      fs.dump(
        example_plugin_configure_file, example_plugin_configure_questions_hash
      )
    end

    Underware::Constants::CONFIGURE_SECTIONS.each do |section|
      context "for #{section}" do
        context 'when no plugins activated' do
          include_examples 'loads_core_configure_questions', section
        end

        context 'when plugin activated' do
          before do
            Underware::Plugins.activate!('example')
          end

          let(:plugin_enabled_question) do
            questions = sections_to_loaded_questions[section]
            questions.find do |question|
              question.content.identifier ==
                Underware::Plugins.enabled_question_identifier('example')
            end
          end

          include_examples 'loads_core_configure_questions', section
          include_examples 'includes_generated_plugin_enabled_question', section

          it "question has plugin questions for #{section} as dependents" do
            plugin_question = plugin_enabled_question.children.first
            content = plugin_question.content
            expect(content.identifier)
              .to eq("example_plugin_#{section}_identifier")
            # NOTE: plugin name has been prepended to question to indicate
            # where this question comes from.
            expect(content.question)
              .to eq("[example] example_plugin_#{section}_question")

            plugin_dependent_question = plugin_question.children.first

            # As above, plugin name has been prepended to dependent question.
            expect(plugin_dependent_question.content.question)
              .to eq "[example] example_plugin_#{section}_dependent_question"
          end

          context 'when no configure.yaml for plugin' do
            before do
              fs = FileUtils
              fs.rm_rf example_plugin_dir
              fs.mkdir_p example_plugin_dir
            end

            include_examples 'includes_generated_plugin_enabled_question' \
              , section

            it 'generated question has no dependents' do
              expect(plugin_enabled_question.children).to be_empty
            end
          end
        end
      end
    end
  end
end
