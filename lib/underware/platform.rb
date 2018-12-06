
require 'underware/template'

module Underware
  Platform = Struct.new(:name) do
    def self.all
      platforms_glob = "#{FilePath.platform_configs_dir}/*.yaml"
      Pathname.glob(platforms_glob).map do |config_path|
        name = config_path.basename.sub_ext('').to_s
        new(name)
      end
    end

    def render_templates
      namespaces.each do |namespace|
        render_templates_for_namespace(namespace)
      end
    end

    private

    def namespaces
       [alces.domain] + alces.groups + alces.nodes
    end

    def alces
      @alces ||= Namespaces::Alces.new(platform: name)
    end

    def render_templates_for_namespace(namespace)
      scope_type = namespace.scope_type
      templates = platform_templates[scope_type] + content_templates[scope_type]
      templates.each { |template| template.render_for(namespace) }
    end

    def platform_templates
      # We cache this so we only load the platform templates once when a single
      # Platform instance is reused to render for multiple namespaces.
      @platform_templates ||=
        Template.all_under_directory(name)
    end

    def content_templates
      # Similarly cache this, though since content templates are shared between
      # platforms these may still be loaded multiple times, once per Platform
      # instance which is rendered against.
      @content_templates ||=
        Template.all_under_directory(Constants::CONTENT_DIR_NAME)
    end
  end
end
