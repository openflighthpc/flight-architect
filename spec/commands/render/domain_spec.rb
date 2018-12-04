
require 'underware/commands/render/domain'

RSpec.describe Underware::Commands::Render::Domain do
  def run_command(template_path)
    Underware::AlcesUtils.redirect_std(:stdout) do
      Underware::Utils.run_command(
        Underware::Commands::Render::Domain, template_path
      )
    end[:stdout].read
  end

  let :template do
    template_contents = <<~TEMPLATE.strip_heredoc
      Rendered with scope: <%= scope.class %>
    TEMPLATE

    Tempfile.create.tap { |t| t.write(template_contents) }
  end

  it 'renders template against the domain and outputs result' do
    output = run_command(template.path)

    expect(output).to eq "Rendered with scope: Underware::Namespaces::Domain\n"
  end
end
