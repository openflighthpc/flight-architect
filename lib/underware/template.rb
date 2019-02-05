
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

      def templates_in_dir(cluster, dir, scope_type:)
        paths = DataPath.cluster(cluster)
        glob = paths.template_file('**/*', dir: dir, scope: scope_type)
        Pathname.glob(glob)
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
      template_dir, _, *rest = relative_path.each_filename.to_a

      # Platform specific file are stored separately from the core templates
      platform = namespace.platform.to_s
      platform_template = (template_dir == platform)

      data_path.rendered_file(*rest,
                              platform: platform,
                              scope: namespace.scope_type,
                              name: namespace.name,
                              core: !platform_template)
    end
  end
end
