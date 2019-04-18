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

require 'underware/command_helpers/base_command'
require 'underware/configurator'
require 'underware/managed_file'

module Underware
  module CommandHelpers
    class ConfigureCommand < BaseCommand
      private

      def run
        configurator.configure(answers)
        custom_configuration
      end

      def answers
        if options.answers
          JSON.parse(options.answers).deep_transform_keys(&:to_sym)
        end
      rescue StandardError => e
        err = AnswerJSONSyntax.new('An error occurred parsing the answer JSON')
        err.set_backtrace(e.backtrace)
        raise err
      end

      def handle_interrupt(_e)
        abort 'Exiting without saving...'
      end

      def custom_configuration
        # Custom additional configuration for a `configure` command, if any,
        # should be performed in this method in subclasses.
      end

      def answer_file
        raise NotImplementedError
      end

      def relative_answer_file
        answer_file.sub("#{FilePath.answers_dir}/", '')
      end

      def dependency_hash
        {
          optional: {
            configure: [relative_answer_file],
          },
        }
      end

      def configurator
        raise NotImplementedError
      end
    end
  end
end
