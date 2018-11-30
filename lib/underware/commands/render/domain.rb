
module Underware
  module Commands
    module Render
      class Domain < CommandHelpers::BaseCommand
        private

        def run
          template_path = args.first
          puts alces.render_file(template_path)
        end
      end
    end
  end
end
