
require 'underware/commands/render/node'

RSpec.describe Underware::Commands::Render::Node do
  include Underware::AlcesUtils

  def run_command(*args)
    Underware::AlcesUtils.redirect_std(:stdout) do
      Underware::Utils.run_command(
        Underware::Commands::Render::Node, *args
      )
    end[:stdout].read
  end

  Underware::AlcesUtils.mock self, :each do
    mock_node(test_node_name)
  end

  let :test_node_name { 'testnode01' }

  let :template do
    Tempfile.create.tap do |t|
      t.write("Rendered with scope: <%= scope.class %>\nScope name: <%= scope.name %>")
    end
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
