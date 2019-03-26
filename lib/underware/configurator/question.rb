
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

require 'highline'
require 'underware/patches/highline'

HighLine::Question.prepend Underware::Patches::HighLine::Question
HighLine::Menu.prepend Underware::Patches::HighLine::Menu

module Underware
  class Configurator
    class Question
      def initialize(question_node, progress_indicator)
        @question_node = question_node
        @highline = HighLine.new
        @progress_indicator = progress_indicator
      end

      attr_accessor :default
      delegate :identifier, to: :question_node

      def ask
        method = choices.nil? ? "ask_#{type}_question" : 'ask_choice_question'
        question_node.answer = send(method) { |q| configure_question(q) }
      end

      private

      attr_reader :question_node, :highline, :progress_indicator
      delegate :choices, :optional, :text, to: :question_node

      def configure_question(highline_question)
        highline_question.readline = use_readline?
        highline_question.default = default_input
        validate_highline_answer_given(highline_question)
      end

      def validate_highline_answer_given(highline_question)
        # Do not override built-in HighLine validation for `agree` questions,
        # which will already cause the question to be re-prompted until a valid
        # answer is given (rather than just accepting any non-empty answer, as
        # our validation below does).
        return if type.boolean?

        # The answer does not need to be given if there is a default or if
        # it is optional
        return if default || optional

        highline_question.validate = lambda { |input| !input.empty? }
        # Override error shown when this validation fails (see
        # https://www.rubydoc.info/github/JEG2/highline/master/HighLine%2FQuestion:responses).
        highline_question.responses[:not_valid] = 'An answer is required for this question.'
      end

      def use_readline?
        # Don't provide readline bindings for boolean questions, in this case
        # they cause an issue where the question is repeated twice if no/bad
        # input is entered, and they are not really necessary in this case.
        return false if type.boolean?

        Underware::Configurator.use_readline
      end

      def default_input
        # For password questions we don't want to set a default on the HighLine
        # question itself as:
        # a. it will be an encrypted password from previous `configure`, and so
        # useless/confusing to show to a user;
        # b. `ask_password_question` handles changing or retaining a previous
        # password itself as needed, without the re-encryption which would
        # occur if we set the default to a previously encrypted password here.
        case type.to_sym
        when :boolean then human_readable_boolean_default
        when :password then nil
        else default&.to_s
        end
      end

      # Default for a boolean question which has a previous answer should be
      # set to the input HighLine's `agree` expects, i.e. 'yes' or 'no'.
      def human_readable_boolean_default
        return nil if default.nil?
        default ? 'yes' : 'no'
      end

      def ask_boolean_question
        highline.agree(question_text + ' [yes/no]') { |q| yield q }
      end

      def ask_choice_question
        offer_choice_between(choices) { |q| yield q }
      end

      def offer_choice_between(possible_choices)
        highline.choose(*possible_choices) do |menu|
          menu.prompt = question_text
          yield menu
        end
      end

      def ask_integer_question
        highline.ask(question_text, Integer) { |q| yield q }
      end

      def ask_string_question
        highline.ask(question_text) { |q| yield q }
      end

      def ask_interface_question
        if available_network_interfaces.length == 1
          default_to_first_interface
        else
          offer_choice_between(available_network_interfaces) { |q| yield q }
        end
      end

      def available_network_interfaces
        @available_network_interfaces ||= Network.available_interfaces
      end

      def default_to_first_interface
        available_network_interfaces.first.tap do |first_interface|
          $stderr.puts <<~MESSAGE.strip_heredoc
            #{question_text}
            [Only one interface available, defaulting to '#{first_interface}']
          MESSAGE
        end
      end

      def ask_password_question
        $stderr.puts existing_password_present_warning if default

        loop do
          password = ask_for_password(question_text)

          # If no password entered and we have a default, just return this,
          # which will (most likely) be an already encrypted password from
          # previous `configure` that we want to keep.
          return default if password.empty? && default

          confirmation = ask_for_password('Confirm password:')

          return encrypt_password(password) if password == confirmation
          $stderr.puts 'Password and confirmation do not match - please try again.'
        end
      end

      def existing_password_present_warning
        <<~INFO.strip_heredoc
          Password has already been configured - leave blank to keep or
          enter new password to change.

          WARNING: changing password could prevent access to nodes already
          configured with current password.
        INFO
      end

      def ask_for_password(prompt_text)
        highline.ask(prompt_text) do |q|
          configure_question(q)
          q.echo = '*'
        end
      end

      def encrypt_password(plaintext_password)
        # Encrypt password with salt, in format expected by `/etc/shadow` (`$6`
        # => use SHA-512). Relevant links:
        # https://www.cyberciti.biz/faq/understanding-etcshadow-file/ and
        # https://stackoverflow.com/a/5174746/2620402.
        salt = SecureRandom.base64
        plaintext_password.crypt("$6$#{salt}")
      end

      def question_text
        "#{text.strip} #{progress_indicator}"
      end

      def type
        value = question_node.type
        ActiveSupport::StringInquirer.new(value || 'string')
      end
    end
  end
end
