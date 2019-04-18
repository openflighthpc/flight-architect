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
require 'underware/data'
require 'dry-validation'

module Underware
  module Validation
    class Answer
      ERROR_FILE = File.join(File.dirname(__FILE__), 'errors.yaml').freeze

      def initialize(answers, answer_section: nil, question_tree: nil)
        @answers = answers
        @section = answer_section
        @question_tree = question_tree
      end

      def validate
        tests = [
          [:MissingSchema, proc do
            MissingSchema.call(validation_hash)
          end],
          [:AnswerTypeSchema, proc do
            AnswerTypeSchema.call(validation_hash)
          end],
        ]
        tests.each do |(test_name, test_proc)|
          @validation_result = test_proc.call
          @last_ran_test = test_name
          return @validation_result unless @validation_result.success?
        end
        @validation_result
      end

      def error_message
        validate if @validation_result.nil?
        return '' if @validation_result.success?
        msg_header = "Failed to validate answers:\n"
        case @last_ran_test
        when :MissingSchema
          "#{msg_header}" \
          "#{@validation_result.messages[:missing_questions][0].chomp} " \
          "#{@validation_result.output[:missing_questions].join(', ')}"
        when :AnswerTypeSchema
          "#{msg_header}" \
          "A type mismatch has been detected in the following question(s):\n" \
          "#{convert_type_errors(@validation_result).join("\n")}\n"
        end
      end

      def success?
        return true if Constants::SKIP_VALIDATION
        validate if @validation_result.nil?
        @validation_result.success?
      end

      def data
        success? ? answers : (raise ValidationFailure, error_message)
      end

      private

      attr_reader :section, :answers

      def loader
        @loader ||= Validation::Loader.new
      end

      def questions_in_section
        loader.section_tree(section).flatten
      end

      def validation_hash
        @validation_hash ||= begin
          payload = {
            answers: [],
            missing_questions: [],
          }
          answers.each_with_object(payload) do |(question, answer), pay|
            if questions_in_section&.key?(question)
              pay[:answers].push(
                {
                  question: question,
                  answer: answer,
                  type: questions_in_section[question].type,
                }.tap { |h| h[:type] = 'string' if h[:type].nil? }
              )
            else
              pay[:missing_questions].push(question)
            end
          end
        end
      end

      ##
      # When Dry Validation detects a type mismatch, the error message contains
      # the index where the error occurred. This method converts that index to
      # the type-error question(s)
      #
      def convert_type_errors(validation_results)
        validation_results.errors[:answers].keys.map do |error_index|
          validation_results.output[:answers][error_index]
        end
      end

      MissingSchema = Dry::Validation.Schema do
        configure do
          config.messages_file = ERROR_FILE
          config.namespace = 'answer'

          def missing_questions?(value)
            value.empty?
          end
        end

        required(:missing_questions).value(:missing_questions?)
      end

      AnswerTypeSchema = Dry::Validation.Schema do
        configure do
          config.messages_file = ERROR_FILE
          config.namespace = 'answer'

          def answer_type?(value)
            Configure.type_check(value[:type], value[:answer])
          end
        end

        required(:answers).each(:answer_type?)
      end
    end
  end
end
