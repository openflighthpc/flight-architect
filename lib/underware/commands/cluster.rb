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
        <% each do |cluster| -%>
        <%   current = Underware::Config.current_cluster == cluster -%>
        <%=  current ? '*' : ' ' %> <%= cluster %>
        <% end -%>
      ERB

      allow_missing_current_cluster

      private

      def setup; end

      def run
        switch_cluster
        list_clusters
      end

      def switch_cluster
        return unless cluster_input
        Config.update { |c| c.current_cluster = cluster_input }
      end

      def cluster_input
        args.first
      end

      def list_clusters
        puts ERB.new(LIST_TEMPLATE, nil, '-')
                .result(clusters.get_binding)
      end

      def clusters
        @clusters ||= begin
          Dir.glob(DataPath.cluster('*').base)
             .map { |p| File.basename(p) }
        end
      end
    end
  end
end
