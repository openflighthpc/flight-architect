
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

require 'underware/validation/configure'

RSpec.describe Underware::QuestionTree do
  context 'with a nexted question hash' do
    subject { Underware::Validation::Configure.new(question_hash).tree }

    let(:identifier_hash) do
      {
        domain: 'domain_identifier',
        domain2: 'second_domain_identifier',
        group: 'group_identifier',
        node: 'node_identifier',
        dependent: 'dependent_identifier',
        dependent2: 'second_dependent_identifier',
      }
    end

    let(:identifiers) { identifier_hash.values.map(&:to_sym) }

    let(:question_hash) do
      {
        domain: [
          {
            identifier: identifier_hash[:domain],
            question: 'Am I a question for the domain?',
          },
          {
            identifier: identifier_hash[:domain2],
            question: 'Can I have two questions in a section?',
          },
        ],
        group: [
          identifier: identifier_hash[:group],
          question: 'Am I a question for the group?',
          dependent: [
            {
              identifier: identifier_hash[:dependent],
              question: 'Can I have a dependent question?',
            },
            {
              identifier: identifier_hash[:dependent2],
              question: 'Can I have a second dependent question?',
            },
          ],
        ],
        node: [
          identifier: identifier_hash[:node],
          question: 'Am I a question for the node?',
        ],
      }
    end

    shared_examples 'a filtered traversal' do |base_method|
      let(:filtered_method) { :"filtered_#{base_method}" }
      let(:enum) { subject.public_send(filtered_method) }

      it 'is defined' do
        expect(subject).to respond_to(filtered_method)
      end

      it 'only includes questions' do
        enum.each { |q| expect(q).to be_question }
      end

      it 'returns an enumerator when called without a block' do
        expect(enum).to be_a Enumerator
      end

      it 'runs the block for each valid question' do
        num = 0
        subject.send filtered_method do |_q|
          num += 1
        end
        expect(num).to eq(identifiers.length)
      end
    end

    Underware::QuestionTree::BASE_TRAVERSALS.each do |base_method|
      describe "#filtered_#{base_method}" do
        it_behaves_like 'a filtered traversal', base_method
      end
    end

    describe '#identifiers' do
      it 'returns all the identifiers' do
        expect(subject.identifiers).to contain_exactly(*identifiers)
      end
    end

    describe '#question?' do
      # The root is not a question, it stores references to the sections
      it "is false for the Tree's root" do
        expect(subject).not_to be_question
      end

      it 'is false for all section nodes' do
        subject.children.each do |section_node|
          expect(section_node).not_to be_question
        end
      end

      it 'returns true if the identifier is defined' do
        question = described_class.new('', identifier: 'some string')
        expect(question).to be_question
      end
    end

    describe '#questions_length' do
      it 'does not include the non questions in the length' do
        expect(subject.questions_length).to eq(identifiers.length)
      end
    end
  end

  describe '#root_defaults' do
    let(:domain_question) do
      { identifier: 'domain_question' }
    end

    let(:group_question) do
      { identifier: 'group_question' }
    end

    let(:node_question) do
      { identifier: 'node_question' }
    end

    let(:correct_defaults) do
      {
        domain_question[:identifier].to_sym => 'domain_default',
        group_question[:identifier].to_sym => 'group_default',
        node_question[:identifier].to_sym => 'node_default',
      }
    end

    let(:question_hash) do
      {
        domain: make('domain_default', domain_question),
        group: make('group_default', domain_question, group_question),
        node: make('node_default',
                   domain_question,
                   group_question,
                   node_question),
      }
    end

    def make(default, *questions)
      questions.map do |question|
        question.merge default: default, question: 'not important'
      end
    end

    let(:tree) { Underware::Validation::Configure.new(question_hash).tree }

    [:domain, :group, :node].each do |section|
      context "when called on the '#{section}' section" do
        subject { tree.section_tree(section) }

        it 'uses the merged default hash' do
          expect(subject.root_defaults).to eq(correct_defaults)
        end
      end
    end
  end
end
