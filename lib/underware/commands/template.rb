
module Underware
  module Commands
    class Template < CommandHelpers::BaseCommand
      private

      def run
        domain_templates_glob = "#{FilePath.templates_dir}/*/domain/*"
        domain_templates = Pathname.glob(domain_templates_glob)
        domain_templates.each do |template|
          relative_path = template.relative_path_from(Pathname.new(FilePath.templates_dir))

          rendered_path = Pathname.new(FilePath.rendered).join(relative_path)
          FileUtils.mkdir_p rendered_path.dirname

          platform = relative_path.to_s.split(File::SEPARATOR).first
          # XXX Stop recreating new Alces for every template.
          platform_alces = Namespaces::Alces.new(platform: platform)
          rendered_template = platform_alces.render_file(template)
          File.write(rendered_path, rendered_template)
        end
      end
    end
  end
end
