
require 'underware/platform'

module Underware
  module Commands
    class Template < CommandHelpers::BaseCommand
      private

      # Rendered file directories to preserve when `template` is run (all other
      # directories will be cleared out on each `template` run, so that only
      # latest rendered files are present).
      PRESERVE_RENDERED_DIRS = [Constants::RENDERED_SYSTEM_FILES_PATH]

      def run
        clear_current_rendered_dir
        Platform.all.each(&:render_templates)
      end

      def clear_current_rendered_dir
        Pathname.new(FilePath.rendered).children.map(&:to_s).each do |rendered_dir|
          unless PRESERVE_RENDERED_DIRS.include?(rendered_dir)
            FileUtils.rm_rf(rendered_dir)
          end
        end
      end
    end
  end
end
