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

module Underware
  module CommandHelpers
    module Clusters
      def self.included(base)
        base.extend(ClassMethods)
        current_cluster_existence_check(base)
      end

      def self.current_cluster_existence_check(base)
        base.register_dependency do
          next if self.class.allow_missing_current_cluster(fetch: true)
          next if cluster_exists?(__config__.current_cluster)
          raise DataError, <<~ERROR.chomp
            The current cluster '#{__config__.current_cluster}' does not exist.
            To resolve this error, either:
            1. `underware init` a new cluster, or
            2. `underware cluster` to an existing cluster
          ERROR
        end
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
    end
  end
end
