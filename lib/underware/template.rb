
module Underware
  Template = Struct.new(:template_path) do
    TEMPLATES_DIR_PATH = Pathname.new(FilePath.templates_dir)

    class << self
      def all_under_directory(templates_dir_name)
        [:domain, :group, :node].map do |scope_type|
          [
            scope_type,
            templates_in_dir(templates_dir_name, scope_type: scope_type)
          ]
        end.to_h
      end

      private

      def templates_in_dir(templates_dir_name, scope_type:)
        glob = "#{TEMPLATES_DIR_PATH}/#{templates_dir_name}/#{scope_type}/**/*"
        Pathname.glob(glob).select(&:file?).map do |template_path|
          new(template_path)
        end
      end
    end

    def render_for(namespace)
      rendered_path = rendered_path_for_namespace(namespace)
      rendered_template = namespace.render_file(template_path)

      FileUtils.mkdir_p rendered_path.dirname
      File.write(rendered_path, rendered_template)
    end

    private

    def rendered_path_for_namespace(namespace)
      relative_path = template_path.relative_path_from(TEMPLATES_DIR_PATH)

      # Content templates should be rendered once for each platform, to
      # platform-specific directory, therefore if template path begins with
      # 'content' directory this should be replaced with platform name in
      # rendered path.
      relative_rendered_path = relative_path
        .sub(/^#{Constants::CONTENT_DIR_NAME}/, namespace.platform.to_s)
        .sub(*namespace_identifier_sub_args(namespace))

      Pathname.new(FilePath.rendered).join(relative_rendered_path)
    end

    def namespace_identifier_sub_args(namespace)
      scope_type = namespace.scope_type
      case scope_type
      when :domain then ['', '']
      when :group then ['group', "group/#{namespace.name}"]
      when :node then ['node', "node/#{namespace.name}"]
      else raise "Unhandled scope type: #{scope_type}"
      end
    end
  end
end
