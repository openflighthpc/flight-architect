# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2019 Stephen F. Norledge and Alces Software Ltd.
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
  class DataPath
    def initialize(cluster: nil)
      @cluster = cluster
    end

    def base
      if cluster
        File.join(Constants::UNDERWARE_STORAGE_PATH, 'clusters', cluster)
      else
        File.join(Constants::UNDERWARE_INSTALL_PATH, 'data')
      end
    end

    def relative(*relative_path)
      File.join(base, *relative_path)
    end

    def template(*relative_path)
      relative('templates', *relative_path)
    end

    # Generate a list of relative path methods
    {
      configure: 'configure.yaml'
    }.each do |method, path|
      define_method(method) { relative(*Array.wrap(path)) }
    end

    private

    attr_reader :cluster
  end
end
