
# frozen_string_literal: true

require 'underware/command_helpers/configure_command'
require 'underware/constants'

module Underware
  module Commands
    module Configure
      class Node < CommandHelpers::ConfigureCommand
        private

        attr_reader :node_name

        def setup
          @node_name = args.first
        end

        def configurator
          @configurator ||=
            Configurator.for_node(alces, node_name)
        end

        def answer_file
          FilePath.node_answers(node_name)
        end

        def custom_configuration
          return if alces.nodes.find_by_name(node_name)
          ClusterAttr.update('something') { |a| a.add_nodes(node_name) }
        end
      end
    end
  end
end
