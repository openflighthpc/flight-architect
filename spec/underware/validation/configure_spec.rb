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
require 'underware/file_path'
require 'underware/data'
require 'underware/constants'
require 'underware/spec/alces_utils'

RSpec.describe Underware::Validation::Configure do
  include Underware::AlcesUtils

  before do
    FakeFS::FileSystem.clone(Underware::FilePath.dry_validation_errors)
  end

  let(:file_path) { Underware::FilePath }

  let(:correct_hash) do
    {
      ##
      # Questions are not part of the specification for a valid configure.yaml
      # file. However they have been white listed as a valid top level key. This
      # means the 'questions' block can be used to store references to questions
      # using YAML anchors in any layout of the users choosing. (As long as the
      # other question blocks are valid)
      #
      questions: {
        questions: 'Not part of the specification for a valid file',
      },

      domain: [
        {
          identifier: 'string_question',
          question: 'Am I a string question without a default and type?',
        },
        {
          identifier: 'integer_question',
          question: 'Am I an integer question with a default?',
          type: 'integer',
          default: 10,
        },
        {
          identifier: 'boolean_true',
          question: 'Can I have a boolean true (/yes) default?',
          type: 'boolean',
          default: true,
        },
      ],

      group: [
        {
          identifier: 'string_question',
          question: 'Am I a string question without a type but with a default?',
          default: 'yes I am a string',
        },
        {
          identifier: 'integer_question',
          question: 'Am I a integer question without a default?',
          type: 'integer',
        },
        {
          identifier: 'boolean_false',
          question: 'Can I have a boolean false (/no) default?',
          type: 'boolean',
          default: false,
        },
        {
          identifier: 'dependent_parent',
          question: 'Do I have dependent questions?',
          dependent: [
            {
              identifier: 'basic_dependent_question',
              question: 'Can there be a single level dependent question?',
            },
            {
              identifier: 'mid_level_dependent_question',
              question: 'Can there be multiple levels of dependency?',
              dependent: [
                {
                  identifier: 'leaf_level_dependent_question',
                  question: 'Am I a leaf of the question tree?',
                },
              ],
            },
          ],
        },
      ],

      node: [
        {
          identifier: 'string_question',
          question: 'Am I a string question with a type and default?',
          type: 'string',
          default: 'yes I am a string',
        },
        {
          identifier: 'string_empty_default',
          question: 'My default is a empty string?',
          default: '',
        },
      ],
    }
  end

  def run_configure_validation(my_hash = {})
    Underware::Validation::Configure.new(my_hash).tree
  end

  def expect_validation_failure(my_hash, msg_regex)
    expect do
      run_configure_validation(my_hash)
    end.to raise_error(Underware::ValidationFailure, msg_regex)
  end

  context 'with a valid input' do
    it 'passes with questions key' do
      expect(run_configure_validation(correct_hash))
        .to be_a(Underware::QuestionTree)
    end

    it 'passes without questions key' do
      correct_hash.delete(:questions)
      expect(run_configure_validation(correct_hash))
        .to be_a(Underware::QuestionTree)
    end
  end

  context 'with general invalid inputs' do
    it 'fails with invalid top level keys' do
      h = correct_hash.deep_merge(invalid_key: true)
      expect_validation_failure(h, /invalid top level key/)
    end

    it 'fails if sections are not an array' do
      h = correct_hash.deep_merge(group: { key: 'I am not an array' })
      expect_validation_failure(h, /must be an array/)
    end
  end

  context 'with invalid question fields' do
    context 'with invalid identifier' do
      it 'fails when missing' do
        h = correct_hash
            .deep_merge(group: [{ question: 'I have no identifier' }])
        expect_validation_failure(h, /is missing/)
      end

      it 'fails when empty' do
        h = correct_hash.deep_merge(group: [{
                                      question: 'I have no identifier',
                                      identifier: '',
                                    }])
        expect_validation_failure(h, /must be filled/)
      end
    end

    context 'invalid dependent question' do
      it 'fails if the identifier is missing' do
        h = correct_hash.merge(
          domain: [
            {
              identifier: 'bad_parent',
              question: 'Am I a bad question parent?',
              dependent: [
                {
                  question: 'Am I missing my identifier',
                },
              ],
            },
          ]
        )
        expect_validation_failure(h, /is missing/)
      end

      it 'fails if the dependent field is not an array' do
        h = correct_hash.merge(
          domain: [{
            identifier: 'bad_parent',
            question: 'Is my dependent field an array?',
            dependent: {
              identifier: 'dependent_not_array',
              question: 'Should I be an array?',
              default: 'YEP!!',
            },
          }]
        )
        expect_validation_failure(h, /must be an array/)
      end
    end

    context 'with invalid question' do
      it 'fails when missing' do
        h = correct_hash.deep_merge(domain: [{ identifier: 'missing_question' }])
        expect_validation_failure(h, /is missing/)
      end

      it 'fails when empty' do
        h = correct_hash.deep_merge(domain: [{
                                      question: '',
                                      identifier: 'no_question',
                                    }])
        expect_validation_failure(h, /must be filled/)
      end
    end

    it "fails if type isn't supported" do
      h = correct_hash.deep_merge(group: [{
                                    identifier: 'unsupported_type',
                                    question: 'Do I have an unsupported type?',
                                    type: 'Unsupported',
                                  }])
      expect_validation_failure(h, /Is an unsupported question type/)
    end

    it 'fails if the optional input is not true or false' do
      h = correct_hash.deep_merge(group: [{
                                    identifier: 'invalid_optional_flag',
                                    question:
                                      'Do I have a boolean optional input?',
                                    optional: 'I should be true or false',
                                  }])
      expect_validation_failure(h, /must be boolean/)
    end
  end

  context 'with invalid string questions' do
    question = "Do I fail because my default isn't a string?"
    it 'fails with a non-string default with no type specified' do
      h = correct_hash.deep_merge(domain: [{
                                    identifier: 'bad_string_question',
                                    question: question,
                                    default: 10,
                                  }])
      expect_validation_failure(h, /question type/)
    end

    it 'fails with a non-string default with a type specified' do
      h = correct_hash.deep_merge(group: [{
                                    identifier: 'bad_string_question',
                                    question: question,
                                    type: 'string',
                                    default: 10,
                                  }])
      expect_validation_failure(h, /question type/)
    end
  end

  context 'with invalid integer questions' do
    question = 'Do I fail because my default is a string?'
    it 'fails with non-integer default' do
      h = correct_hash.deep_merge(node: [{
                                    identifier: 'bad_integer_question',
                                    question: question,
                                    type: 'integer',
                                    default: '10',
                                  }])
      expect_validation_failure(h, /question type/)
    end
  end

  context 'with invalid boolean questions' do
    question = 'Do I fail because my default is a string?'
    it 'fails with non-boolean default' do
      h = correct_hash.deep_merge(node: [{
                                    identifier: 'bad_integer_question',
                                    question: question,
                                    type: 'boolean',
                                    default: 'I am not valid',
                                  }])
      expect_validation_failure(h, /question type/)
    end
  end

  context 'with invalid choice options' do
    it 'fail when the default is not in the choice list' do
      h = correct_hash.deep_merge(node: [{
                                    identifier:
                                      'choice_question_no_bad_default',
                                    question: 'Is my default valid?',
                                    choice: [
                                      'choice1',
                                      'choice2',
                                      'choice3',
                                    ],
                                    default: 'not in list',
                                  }])
      expect_validation_failure(h, /choice list/)
    end

    it 'fails with inconsistent choice types' do
      h = correct_hash.deep_merge(node: [{
                                    identifier: 'choice_question_no_bad_type',
                                    question: 'Are my choice types valid?',
                                    choice: [
                                      'choice1',
                                      100,
                                      'choice3',
                                    ],
                                  }])
      expect_validation_failure(h, /match the question type/)
    end
  end
end
