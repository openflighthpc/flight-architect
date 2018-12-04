
require 'shared_examples/render_command'
require 'underware/commands/render/domain'

RSpec.describe Underware::Commands::Render::Domain do
  include_context 'render command'

  let :command_args do
    [template.path]
  end

  it 'renders template against the domain and outputs result' do
    output = run_command(template.path)

    expect(output).to include "Rendered with scope: Underware::Namespaces::Domain\n"
  end
end
