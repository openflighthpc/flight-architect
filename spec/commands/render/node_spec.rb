
require 'underware/commands/render/node'

RSpec.describe Underware::Commands::Render::Node do
  def run_command(*args)
    Underware::AlcesUtils.redirect_std(:stdout) do
      Underware::Utils.run_command(
        Underware::Commands::Render::Node, *args
      )
    end[:stdout].read
  end

  before :each do
    allow(Underware::NodeattrInterface)
      .to receive(:all_nodes)
      .and_return([test_node_name])
  end

  let :test_node_name { 'testnode01' }

  let :template do
    template_contents = <<~TEMPLATE.strip_heredoc
      Rendered with scope: <%= scope.class %>
      Scope name: <%= scope.name %>
    TEMPLATE

    Tempfile.create.tap { |t| t.write(template_contents) }
  end

  it 'renders template against the given node and outputs result' do
    output = run_command(test_node_name, template.path)

    expect(output).to include "Rendered with scope: Underware::Namespaces::Node\n"
    expect(output).to include "Scope name: #{test_node_name}\n"
  end

  it 'gives error if node cannot be found' do
    expect do
      run_command('unknown_node01', template.path)
    end.to raise_error(
      Underware::InvalidInput, "Could not find node: unknown_node01"
    )
  end
end
