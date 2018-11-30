
module Underware
  module Commands
    module Render
      class Domain < CommandHelpers::RenderCommand
        private

        def find_namespace(_namespace_name)
          alces.domain
        end
      end
    end
  end
end
