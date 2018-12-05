
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

        content_domain_templates = templates_in_dir(CONTENT_NAME, scope_type: :domain)
        content_group_templates = templates_in_dir(CONTENT_NAME, scope_type: :group)
        content_node_templates = templates_in_dir(CONTENT_NAME, scope_type: :node)

        platforms.each do |platform|
          platform_alces = Namespaces::Alces.new(platform: platform)
          platform_domain_templates = templates_in_dir(platform, scope_type: :domain)

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

          platform_group_templates = templates_in_dir(platform, scope_type: :group)

          group_templates = content_group_templates + platform_group_templates
          platform_alces.groups.each do |group|
            group_templates.each do |template|
              relative_path = template.relative_path_from(Pathname.new(FilePath.templates_dir))

              relative_rendered_path = relative_path
                .sub(/^#{CONTENT_NAME}/, platform)
                .sub('group', "group/#{group.name}")
              rendered_path = Pathname.new(FilePath.rendered).join(relative_rendered_path)
              FileUtils.mkdir_p rendered_path.dirname

              rendered_template = group.render_file(template)
              File.write(rendered_path, rendered_template)
            end
          end

          platform_node_templates = templates_in_dir(platform, scope_type: :node)

          node_templates = content_node_templates + platform_node_templates
          platform_alces.nodes.each do |node|
            node_templates.each do |template|
              relative_path = template.relative_path_from(Pathname.new(FilePath.templates_dir))

              relative_rendered_path = relative_path
                .sub(/^#{CONTENT_NAME}/, platform)
                .sub('node', "node/#{node.name}")
              rendered_path = Pathname.new(FilePath.rendered).join(relative_rendered_path)
              FileUtils.mkdir_p rendered_path.dirname

              rendered_template = node.render_file(template)
              File.write(rendered_path, rendered_template)
            end
          end
        end
      end

      def templates_in_dir(templates_dir_name, scope_type:)
        glob = "#{FilePath.templates_dir}/#{templates_dir_name}/#{scope_type}/*"
        Pathname.glob(glob)
      end
    end
  end
end
