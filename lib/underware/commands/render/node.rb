
module Underware
  module Commands
    module Render
      class Node < CommandHelpers::BaseCommand
        private

        def run
          puts node.render_file(template_path)
        end

        def node
          found_node = alces.nodes.find_by_name(node_name)
          return found_node if found_node
          # XXX We raise similar errors in other places (`NodeIdentifer`
          # module, `AssetEditor` commands) - maybe we should de-duplicate
          # these for consistency.
          raise InvalidInput, "Could not find node: #{node_name}"
        end

        def node_name
          args.first
        end

        def template_path
          args.second
        end
      end
    end
  end
end
