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
  module Commands
    class Cluster < CommandHelpers::BaseCommand
      LIST_TEMPLATE = <<~ERB
        <% config = CommandConfig.load -%>
        <% clusters.each do |cluster| -%>
        <%   current = config.current_cluster == cluster -%>
        <%=  current ? '*' : ' ' %> <%= cluster %>
        <% end -%>
      ERB

      allow_missing_current_cluster

      private

      def setup; end

      def run
        # Load the current_cluster from the config to ensure the default
        # has been created (if required)
        __config__.current_cluster
        switch_cluster if cluster_input
        missing_check
        list_clusters
      end

      def missing_check
        return if cluster_exists?(__config__.current_cluster)
        UnderwareLog.warn <<~WARN.squish.chomp
          The current cluster '#{__config__.current_cluster}' does not exist!
        WARN
      end

      def switch_cluster
        error_if_cluster_missing(cluster_input)
        CommandConfig.update { |c| c.current_cluster = cluster_input }
      end

      def cluster_input
        args.first
      end

      def list_clusters
        puts ERB.new(LIST_TEMPLATE, nil, '-').result(binding)
      end

      def delete_cluster(cluster)
        confirm_delete(cluster)
        FileUtils.rm_rf DataPath.cluster(cluster).base
      end

      def confirm_delete(cluster)
        cli = HighLine.new
        question = "Are you sure you want to delete '#{cluster}' (y/n)?"
        return if cli.agree question
        raise InvalidInput, 'Cancelled delete'
      end

      def error_if_cluster_missing(cluster, action: 'switch to')
        return if cluster_exists?(cluster)
        raise InvalidInput, <<~ERROR.squish
          Can not #{action} '#{cluster}' as the cluster does not exist
        ERROR
      end

      def error_if_deleting_current_cluster(cluster)
        return unless __config__.current_cluster == cluster
        raise InvalidInput, <<~ERROR.chomp
          Can not delete the current cluster, please switch cluster and run:
          '#{Underware::APP_NAME} cluster --delete #{cluster}'
        ERROR
      end

      class Delete < Cluster
        def run
          cluster = cluster_input || __config__.current_cluster
          error_if_deleting_current_cluster(cluster)
          error_if_cluster_missing(cluster, action: 'delete')
          delete_cluster(cluster)
        end
      end
    end
  end
end
