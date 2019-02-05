
module Underware
  Template = Struct.new(:cluster, :relative_path) do
    class << self
      def all_under_directory(cluster, template_dir)
        [:domain, :group, :node].map do |scope_type|
          [
            scope_type,
            templates_in_dir(cluster, template_dir, scope_type: scope_type)
          ]
        end.to_h
      end

      private

      def templates_in_dir(cluster, template_dir, scope_type:)
        paths = DataPath.cluster(cluster)
        Pathname.glob(paths.template(template_dir, scope_type, '**/*'))
                .select(&:file?)
                .map { |p| p.relative_path_from(paths.template) }
                .map { |p| new(cluster, p) }
      end
    end

    def render_for(namespace)
      rendered_path = rendered_path_for_namespace(namespace)
      rendered_template = namespace.render_file(template_path)
      Utils.create_file(rendered_path, content: rendered_template)
    end

    def template_path
      data_path.template(relative_path)
    end

    private

    def data_path
      @data_path ||= DataPath.cluster(cluster)
    end

    def rendered_path_for_namespace(namespace)
      platform_part, scope_type_part, *rest = relative_path.each_filename.to_a

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
