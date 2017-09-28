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

require 'nodeattr_interface'
require 'domain_templates_renderer'
require 'active_support/core_ext/string/strip'
require 'data'

module Metalware
  module Commands
    module Remove
      class Group < CommandHelpers::BaseCommand
        def setup
          @primary_group = args[0]
          @cache = GroupCache.new(config)
        end

        def run
          delete_answer_files
          cache.remove(primary_group)
          update_domain_templates
        end

        private

        attr_reader :primary_group, :cache

        # Deleting a group should not break the genders file, so this error is
        # not expected to run
        GENDERS_INVALID_MESSAGE = <<-EOF.strip_heredoc
          This error is most likely an issue with the Metalware repo you are
          using.
        EOF

        def dependency_hash
          {
            configure: ["groups/#{primary_group}.yaml"],
          }
        end

        def delete_answer_files
          list_of_answer_files.each do |file|
            File.delete(file) if File.file?(file)
          end
        end

        def list_of_answer_files
          NodeattrInterface.nodes_in_primary_group(primary_group)
                           .map { |node| config.node_answers_file(node) }
                           .unshift(config.group_answers_file(primary_group))
        end

        def update_domain_templates
          DomainTemplatesRenderer
            .new(config, genders_invalid_message: GENDERS_INVALID_MESSAGE).render
        end
      end
    end
  end
end
