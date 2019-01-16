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

require 'underware/data_path'

module Underware
  class DataCopy
    def self.init_cluster(cluster)
      new(nil, cluster).all
    end

    def initialize(source_cluster, destination_cluster)
      @source = DataPath.new(cluster: source_cluster)
      @destination = DataPath.new(cluster: destination_cluster)
    end

    def all
      FileUtils.mkdir_p(destination.base)
      Dir.glob(source.relative('*')) do |source_path|
        relative_path = File.basename(source_path)
        destination_path = destination.relative(relative_path)
        FileUtils.copy_entry source_path, destination_path
      end
    end

    private

    attr_reader :source, :destination
  end
end
