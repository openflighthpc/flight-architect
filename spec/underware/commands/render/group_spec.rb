
require 'shared_examples/render_command'
require 'underware/commands/render/group'

RSpec.describe Underware::Commands::Render::Group do
  include_context 'render command'

  before :each do
    Underware::ClusterAttr.update(Underware::Config.current_cluster) do |attr|
      attr.add_group(test_group_name)
    end
  end

  let :test_group_name { 'testgroup' }

  let :command_args do
    [test_group_name, template.path]
  end

  it 'renders template against the given group and outputs result' do
    output = run_command(*command_args)

    expect(output).to include "Rendered with scope: Underware::Namespaces::Group\n"
    expect(output).to include "Scope name: #{test_group_name}\n"
  end

  it 'gives error if group cannot be found' do
    expect do
      run_command('unknown_group01', template.path)
    end.to raise_error(
      Underware::InvalidInput, "Could not find group: unknown_group01"
    )
  end
end
