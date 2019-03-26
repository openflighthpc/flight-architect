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
require 'underware/commands/render/group'

RSpec.describe Underware::Commands::Render::Group do
  include_context 'render command'

  before :each do
    Underware::ClusterAttr.update(Underware::CommandConfig.load.current_cluster) do |attr|
      attr.add_group(test_group_name)
    end
  end

  let(:test_group_name) { 'testgroup' }

  let(:command_args) do
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
