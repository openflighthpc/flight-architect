
module Underware
  module Commands
    class Template < CommandHelpers::BaseCommand
      private

      # Directory name where shared 'content' templates live.
      CONTENT_NAME = 'content'

      def run
        platforms_glob = "#{FilePath.platform_configs_dir}/*.yaml"
        platforms = Pathname.glob(platforms_glob).map do |config_path|
          config_path.basename.sub_ext('').to_s
        end

        content_domain_templates = domain_templates_in_dir(CONTENT_NAME)

        platforms.each do |platform|
          platform_alces = Namespaces::Alces.new(platform: platform)
          platform_domain_templates = domain_templates_in_dir(platform)

          domain_templates = content_domain_templates + platform_domain_templates
          domain_templates.each do |template|
            relative_path = template.relative_path_from(Pathname.new(FilePath.templates_dir))

            # Content templates should be rendered once for each platform, to
            # platform-specific directory, therefore if template path begins
            # with 'content' directory this should be replaced with platform
            # name in rendered path.
            relative_rendered_path = relative_path.sub(/^#{CONTENT_NAME}/, platform)
            rendered_path = Pathname.new(FilePath.rendered).join(relative_rendered_path)
            FileUtils.mkdir_p rendered_path.dirname

            rendered_template = platform_alces.render_file(template)
            File.write(rendered_path, rendered_template)
          end
        end
      end

      def domain_templates_in_dir(templates_dir_name)
        glob = "#{FilePath.templates_dir}/#{templates_dir_name}/domain/*"
        Pathname.glob(glob)
      end
    end
  end
end
