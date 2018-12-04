
# frozen_string_literal: true

module Underware
  module Namespaces
    class Group < HashMergerNamespace
      include Mixins::Name

      attr_reader :index

      def initialize(*args, index:, **kwargs)
        @index = index
        super(*args, **kwargs)
      end

      def nodes
        @nodes ||= begin
          arr = NodeattrInterface.nodes_in_gender(name).map do |node_name|
            alces.nodes.send(node_name)
          end
          UnderwareArray.new(arr)
        end
      end

      def hostlist_nodes
        @short_nodes_string ||= begin
          NodeattrInterface.hostlist_nodes_in_gender(name)
        end
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
