
require 'shared_examples/render_command'
require 'underware/commands/render/node'
require 'underware/cluster_attr'

RSpec.describe Underware::Commands::Render::Node do
  include_context 'render command'

  before :each do
    Underware::ClusterAttr.update(Underware::CommandConfig.load.current_cluster) do |attr|
      attr.add_nodes(test_node_name)
    end
  end

  let(:test_node_name) { 'testnode01' }

  let(:command_args) do
    [test_node_name, template.path]
  end

  it 'renders template against the given node and outputs result' do
    output = run_command(*command_args)

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
