
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
      Utils.create_file(rendered_path, content: rendered_template)
    end

    private

    def rendered_path_for_namespace(namespace)
      relative_path = template_path.relative_path_from(TEMPLATES_DIR_PATH)
      platform_part, scope_type_part, *rest = relative_path.to_s.split(File::SEPARATOR)

      # Content templates should be rendered once for each platform, to
      # platform-specific directory, therefore if platform part of path is
      # 'content' directory this should be replaced with platform name in
      # rendered path.
      if platform_part == Constants::CONTENT_DIR_NAME
        platform_part = namespace.platform.to_s
      end

      namespace_name_dirs = any_namespace_name_dirs(namespace)
      Pathname.new(FilePath.rendered).join(
        platform_part, scope_type_part, *namespace_name_dirs, *rest
      )
    end

    def any_namespace_name_dirs(namespace)
      scope_type = namespace.scope_type
      case scope_type
      when :domain then []
      when :group, :node then [namespace.name]
      else raise "Unhandled scope type: #{scope_type}"
      end
    end
  end
end
