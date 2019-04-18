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

require 'underware/validation/answer'
require 'underware/data'
require 'underware/spec/alces_utils'

RSpec.describe Underware::Validation::Answer do
  include Underware::AlcesUtils
  let(:question_tree) do
    {
      domain: [
        {
          identifier: 'string_question',
          question: 'Am I a string?',
        },
        {
          identifier: 'integer_question',
          question: 'Am I a integer',
          type: 'integer',
        },
        {
          identifier: 'bool_question',
          question: 'Am I a boolean',
          type: 'boolean',
        },
      ],

      group: [],
      node: [],
    }
  end

  let(:valid_answers) do
    {
      string_question: 'string',
      integer_question: 100,
      bool_question: true,
    }
  end

  def run_answer_validation(answers)
    Underware::Data.dump(Underware::FilePath.configure, question_tree)
    validator = Underware::Validation::Answer.new(answers,
                                                  answer_section: :domain)
    [validator.validate, validator]
  end

  def get_question_with_an_incorrect_type(results)
    expect(results.errors).not_to be_empty
    expect(results.errors[:answers].keys.length).to be >= 1
    results.errors[:answers].keys.map do |error_index|
      results.output[:answers][error_index]
    end
  end

  context 'with a valid answer hash' do
    it 'returns successfully' do
      errors = run_answer_validation(valid_answers)[0].errors
      expect(errors.keys).to be_empty
    end
  end

  context 'with an invalid answer hash' do
    it 'contains an answer to a missing question' do
      answers = {
        a_missing_question: 'I do not appear in configure.yaml',
      }
      results, validator = run_answer_validation(answers)
      expect(results.errors.keys).to include(:missing_questions)
      expect(validator.error_message).to include('a_missing_question')
    end

    context 'with type mismatch questions' do
      it 'detects string question' do
        answers = valid_answers.tap do |a|
          a[:string_question] = 100
        end
        results = run_answer_validation(answers)[0]
        error_question = get_question_with_an_incorrect_type(results)[0]
        expect(error_question[:question]).to eq(:string_question)
      end

      it 'detects integer question' do
        answers = valid_answers.tap do |a|
          a[:integer_question] = 'I should not be a string'
        end
        results = run_answer_validation(answers)[0]
        error_question = get_question_with_an_incorrect_type(results)[0]
        expect(error_question[:question]).to eq(:integer_question)
      end

      it 'detects boolean question' do
        answers = valid_answers.tap do |a|
          a[:bool_question] = 'I should not be a string'
        end
        results = run_answer_validation(answers)[0]
        error_question = get_question_with_an_incorrect_type(results)[0]
        expect(error_question[:question]).to eq(:bool_question)
      end

      it 'detects multiple errors' do
        answers = valid_answers.tap do |a|
          a[:string_question] = false
          a[:integer_question] = true
          a[:bool_question] = true # Intentionally correct
        end
        _results, validator = run_answer_validation(answers)
        msg = validator.error_message
        expect(msg).to include('string_question', 'integer_question')
        expect(msg).not_to include('bool_question')
      end
    end
  end
end
