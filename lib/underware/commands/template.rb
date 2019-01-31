
require 'underware/platform'

module Underware
  module Commands
    class Template < CommandHelpers::BaseCommand
      private

      def run
        clear_current_rendered_dir
        Platform.all(__config__.current_cluster).each(&:render_templates)
      end

      def clear_current_rendered_dir
        FileUtils.mkdir_p(FilePath.rendered)
        Pathname.new(FilePath.rendered).children.map(&:to_s).each do |rendered_dir|
          FileUtils.rm_rf(rendered_dir)
        end
      end
    end
  end
end
