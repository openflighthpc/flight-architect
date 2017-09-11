# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Metalware.
#
# Alces Metalware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Metalware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Metalware, please visit:
# https://github.com/alces-software/metalware
#==============================================================================

require 'command_helpers/base_command'
require 'configurator'
require 'domain_templates_renderer'
require 'active_support/core_ext/string/strip'

module Metalware
  module CommandHelpers
    class ConfigureCommand < BaseCommand
      private

      GENDERS_INVALID_MESSAGE = <<-EOF.strip_heredoc
        You should be able to fix this error by re-running the `configure`
        command and correcting the invalid input, or by manually editing the
        appropriate answers file or template and using the `configure rerender`
        command to re-render the templates.
      EOF

      def run
        configurator.configure(answers)
        custom_configuration
        render_domain_templates
      end

      def answers
        JSON.parse(options.answers) if options.answers
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
        answer_file.sub("#{config.answer_files_path}/", '')
      end

      def dependency_hash
        {
          repo: ['configure.yaml'],
          optional: {
            configure: [relative_answer_file],
          },
        }
      end

      def configurator
        raise NotImplementedError
      end

      # Render the templates which are relevant across the whole domain; these
      # are re-rendered at the end of every configure command as the data used
      # in the templates could change with each command.
      def render_domain_templates
        DomainTemplatesRenderer.new(
          config,
          genders_invalid_message: GENDERS_INVALID_MESSAGE
        ).render
      end
    end
  end
end
