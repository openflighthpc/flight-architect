
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

require 'underware/answers_table_creator'
require 'underware/validation/loader'

RSpec.describe Underware::AnswersTableCreator do
  include Underware::AlcesUtils

  subject do
    described_class.new(alces)
  end

  let(:raw_configure_data) do
    {
      domain: [{
        identifier: 'question_1',
        question: 'question 1',
      }],
      group: [
        {
          identifier: 'question_1',
          question: 'question 1',
        },
        {
          identifier: 'question_2',
          question: 'question 2',
          type: 'integer',
        },
      ],
      node: [
        {
          identifier: 'question_1',
          question: 'question 1',
        },
        {
          identifier: 'question_2',
          question: 'question 2',
          type: 'integer',
        },
        {
          identifier: 'question_3',
          question: 'question 3',
        },
      ],
    }
  end

  let(:question_tree) do
    Underware::Validation::Configure.new(raw_configure_data).tree
  end

  let!(:loader) do
    l = Underware::Validation::Loader.new
    allow(l).to receive(:question_tree).and_return(question_tree)
    allow(Underware::Validation::Loader).to receive(:new).and_return(l)
    l
  end

  let(:domain_answers) do
    { question_1: 'domain question 1' }
  end

  let(:group_answers) do
    { question_1: 'group question 1', question_2: 11 }
  end

  let(:node_answers) do
    {
      question_1: 'node question 1',
      question_2: 13,
      question_3: 'node question 3',
    }
  end

  let(:group_name) { 'testnodes' }
  let(:node_name) { 'testnode01' }

  Underware::AlcesUtils.mock self, :each do
    answer(alces.domain, domain_answers)
    answer(mock_node(node_name, group_name), node_answers)
    answer(mock_group(group_name), group_answers)
  end

  describe '#domain_table' do
    it 'creates table with questions and domain answers' do
      expected_table = Terminal::Table.new(
        headings: ['Question', 'Domain'],
        rows: [
          ['question_1', '"domain question 1"'],
          ['question_2', 'nil'],
          ['question_3', 'nil'],
        ]
      )

      # In this and following tests, convert tables to strings so can compare
      # output rather than as objects (which will never be equal as we create
      # different `Table`s).
      expect(
        subject.domain_table.to_s
      ).to eq expected_table.to_s
    end
  end

  describe '#group_table' do
    it 'creates table with questions, and domain and primary group answers' do
      expected_table = Terminal::Table.new(
        headings: ['Question', 'Domain', "Group: #{group_name}"],
        rows: [
          ['question_1', '"domain question 1"', '"group question 1"'],
          ['question_2', 'nil', '11'],
          ['question_3', 'nil', 'nil'],
        ]
      )

      expect(
        subject.group_table(group_name).to_s
      ).to eq expected_table.to_s
    end
  end

  describe '#node_table' do
    it 'creates table with answers for domain, primary group and node' do
      expected_table = Terminal::Table.new(
        headings:
          ['Question', 'Domain', "Group: #{group_name}", "Node: #{node_name}"],
        rows: [
          ['question_1', '"domain question 1"',
           '"group question 1"', '"node question 1"'],
          ['question_2', 'nil', '11', '13'],
          ['question_3', 'nil', 'nil', '"node question 3"'],
        ]
      )

      expect(
        subject.node_table(node_name).to_s
      ).to eq expected_table.to_s
    end
  end
end
