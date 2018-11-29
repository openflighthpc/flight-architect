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

module Underware
  module FilePath
    class ConfigPath
      attr_reader :base

      def initialize(base:)
        @base = base
      end

      def domain_config
        path 'domain'
      end

      def local_config
        path 'local'
      end

      def path(name)
        file_name = "#{name}.yaml"
        File.join(config_dir, file_name)
      end

      def config_dir
        File.join(base, 'config')
      end

      # These are the names we currently expect to use to access the different
      # config paths elsewhere. Since they all go the same place maybe we don't
      # need different methods. Or maybe we should change configs to use same
      # file structure as answers, which is more structured and helps prevent
      # conflicts.
      alias group_config path
      alias node_config path
    end
  end
end
