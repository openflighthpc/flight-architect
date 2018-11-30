
module Underware
  module Commands
    module Render
      class Group < CommandHelpers::BaseCommand
        private

        def run
          puts group.render_file(template_path)
        end

        def group
          found_group = alces.groups.find_by_name(group_name)
          return found_group if found_group
          raise InvalidInput, "Could not find group: #{group_name}"
        end

        def group_name
          args.first
        end

        def template_path
          args.second
        end
      end
    end
  end
end
