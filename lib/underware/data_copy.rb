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

require 'underware/data_path'

module Underware
  class DataCopy
    # NOTE: Deprecated! Use the `overlay_to_cluster` method instead
    def self.init_cluster(cluster)
      overlay_to_cluster(nil, cluster).all
    end

    def self.overlay_to_cluster(overlay, cluster)
      error_if_invalid_cluster(cluster)
      overlay_path = DataPath.overlay(overlay)
      cluster_path = DataPath.cluster(cluster)
      new(overlay_path, cluster_path)
    end

    private_class_method

    def self.error_if_invalid_cluster(cluster)
      return if cluster && cluster.present?
      raise InternalError, <<~ERROR
        Can not copy to cluster: #{cluster.inspect}
      ERROR
    end

    def initialize(source, destination)
      @source = source
      @destination = destination
    end

    def all
      FileUtils.mkdir_p(destination.base)
      Dir.glob(source.join('*')) do |source_path|
        relative_path = File.basename(source_path)
        destination_path = destination.join(relative_path)
        FileUtils.copy_entry source_path, destination_path
      end
    end

    private

    attr_reader :source, :destination
  end
end
