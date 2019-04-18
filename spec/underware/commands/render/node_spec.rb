# =============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Architect.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Architect is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Architect. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Architect, please visit:
# https://github.com/openflighthpc/flight-architect
# ==============================================================================

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
