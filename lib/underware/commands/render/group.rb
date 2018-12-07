
module Underware
  module Commands
    module Render
      class Group < CommandHelpers::RenderCommand
        private

        def find_namespace(namespace_name)
          alces.groups.find_by_name(namespace_name)
        end
      end
    end
  end
end
