
module Underware
  module Commands
    module Render
      class Node < CommandHelpers::RenderCommand
        private

        def find_namespace(namespace_name)
          alces.nodes.find_by_name(namespace_name)
        end
      end
    end
  end
end
