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
  module Commands
    class Cluster < CommandHelpers::BaseCommand
      LIST_TEMPLATE = <<~ERB
        <% clusters.each do |cluster| -%>
        <%   current = Underware::Config.current_cluster == cluster -%>
        <%=  current ? '*' : ' ' %> <%= cluster %>
        <% end -%>
      ERB

      allow_missing_current_cluster

      private

      def setup; end

      def run
        options.delete ? run_delete : run_normal
      end

      def run_normal
        switch_cluster if cluster_input
        missing_check
        list_clusters
      end

      def run_delete
        cluster = cluster_input || Config.current_cluster
        error_if_deleting_current_cluster(cluster)
        error_if_cluster_missing(cluster, action: 'delete')
        confirm_delete(cluster)
      end

      def missing_check
        return if cluster_exists?(Config.current_cluster)
        UnderwareLog.warn <<~WARN.squish.chomp
          The current cluster '#{Config.current_cluster}' does not exist!
        WARN
      end

      def switch_cluster
        error_if_cluster_missing(cluster_input)
        Config.update { |c| c.current_cluster = cluster_input }
      end

      def cluster_input
        args.first
      end

      def confirm_delete(cluster)
        cli = HighLine.new
        question = "Are you sure you want to delete '#{cluster}' (y/n)?"
        return if cli.agree question
        raise InvalidInput, 'Cancelled delete'
      end

      def list_clusters
        puts ERB.new(LIST_TEMPLATE, nil, '-').result(binding)
      end

      def error_if_cluster_missing(cluster, action: 'switch to')
        return if cluster_exists?(cluster)
        raise InvalidInput, <<~ERROR.squish
          Can not #{action} '#{cluster}' as the cluster does not exist
        ERROR
      end

      def error_if_deleting_current_cluster(cluster)
        return unless Config.current_cluster == cluster
        raise InvalidInput, <<~ERROR.chomp
          Can not delete the current cluster, please switch cluster and run:
          '#{Underware::APP_NAME} cluster --delete #{cluster}'
        ERROR
      end
    end
  end
end
