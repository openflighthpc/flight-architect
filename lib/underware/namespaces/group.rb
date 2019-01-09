
# frozen_string_literal: true

module Underware
  module Namespaces
    class Group < HashMergerNamespace
      include Mixins::Name

      attr_reader :index

      def initialize(*args, index:)
        @index = index
        super(*args)
      end

      def nodes
        @nodes ||= begin
          arr = alces.cluster_attr.nodes_in_group(name).map do |node_name|
            alces.nodes.send(node_name)
          end
          UnderwareArray.new(arr)
        end
      end

      def hostlist_nodes
        Underware::ClusterAttr.collapse(*nodes.map(&:name))
      end

      private

      def white_list_for_hasher
        super.concat([:index, :nodes, :hostlist_nodes])
      end

      def hash_merger_input
        super.merge(groups: [name])
      end

      def additional_dynamic_namespace
        { group: self }
      end
    end
  end
end
