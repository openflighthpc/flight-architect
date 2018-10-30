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

require 'underware/command_helpers/configure_command'
require 'underware/constants'
require 'underware/group_cache'

module Underware
  module Commands
    module Configure
      class Group < CommandHelpers::ConfigureCommand
        private

        attr_reader :group_name, :cache

        def setup
          @group_name = args.first
        end

        def configurator
          @configurator ||=
            Configurator.for_group(alces, group_name)
        end

        def answer_file
          file_path.group_answers(group_name)
        end

        def custom_configuration
          GroupCache.update { |c| c.add group_name }
        end
      end
    end
  end
end
