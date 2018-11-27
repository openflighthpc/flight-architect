# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Underware.
#
# Alces Underware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Underware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Underware, please visit:
# https://github.com/alces-software/underware
#==============================================================================

require 'underware/command_helpers/base_command'
require 'underware/configurator'
require 'active_support/core_ext/string/strip'
require 'underware/managed_file'

module Underware
  module CommandHelpers
    class ConfigureCommand < BaseCommand
      # XXX This only lives here for now as I'm not sure where it should
      # ideally live, and it needs to be usable from other commands; at some
      # point it should move somewhere better however.
      def self.render_genders
        # The genders file must be templated with a new namespace object as the
        # answers may have changed since they where loaded
        new_alces = Namespaces::Alces.new
        template = FilePath.genders_template
        rendered_genders_content = new_alces.render_file(template)
        full_new_genders_content = ManagedFile.content(
          FilePath.genders, rendered_genders_content
        )
        File.write(FilePath.genders, full_new_genders_content)
      end

      private

      def run
        configurator.configure(answers)
        custom_configuration
        self.class.render_genders
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
        answer_file.sub("#{FilePath.answer_files}/", '')
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
