
module Underware
  module Commands
    class Template < CommandHelpers::BaseCommand
      private

      def run
        platforms_glob = "#{FilePath.platform_configs_dir}/*.yaml"
        platforms = Pathname.glob(platforms_glob).map do |config_path|
          config_path.basename.sub_ext('').to_s
        end

        platforms.each do |platform|
          platform_alces = Namespaces::Alces.new(platform: platform)

          domain_templates_glob = "#{FilePath.templates_dir}/#{platform}/domain/*"
          domain_templates = Pathname.glob(domain_templates_glob)

          domain_templates.each do |template|
            relative_path = template.relative_path_from(Pathname.new(FilePath.templates_dir))

            rendered_path = Pathname.new(FilePath.rendered).join(relative_path)
            FileUtils.mkdir_p rendered_path.dirname

            rendered_template = platform_alces.render_file(template)
            File.write(rendered_path, rendered_template)
          end
        end
      end
    end
  end
end
