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
  module CommandHelpers
    module Clusters
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def allow_missing_current_cluster(fetch: false)
          @allow_missing_cluster = true unless fetch
          @allow_missing_cluster
        end
      end

      def clusters
        @clusters ||= begin
          Dir.glob(DataPath.cluster('*').base)
             .map { |p| File.basename(p) }
        end
      end

      def cluster_exists?(cluster)
        clusters.include?(cluster)
      end

      def current_cluster_existence_check
        return if self.class.allow_missing_current_cluster(fetch: true)
        return if cluster_exists?(Config.current_cluster)
        raise DataError, <<~ERROR.chomp
          The current cluster '#{Config.current_cluster}' does not exist.
          To resolve this error, either:
          1. `underware init` a new cluster, or
          2. `underware cluster` to an existing cluster
        ERROR
      end
    end
  end
end
