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
        switch_cluster
        missing_check
        list_clusters
      end

      def missing_check
        return if cluster_exists?(Config.current_cluster)
        UnderwareLog.warn <<~WARN.squish.chomp
          The current cluster '#{Config.current_cluster}' does not exist!
        WARN
      end

      def switch_cluster
        return unless cluster_input
        error_if_cluster_missing(cluster_input)
        Config.update { |c| c.current_cluster = cluster_input }
      end

      def cluster_input
        args.first
      end

      def list_clusters
        puts ERB.new(LIST_TEMPLATE, nil, '-').result(binding)
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

      def error_if_cluster_missing(cluster)
        return if cluster_exists?(cluster)
        raise InvalidInput, <<~ERROR.squish
          Can not switch to '#{cluster}' as the cluster does not exist
        ERROR
      end
    end
  end
end
