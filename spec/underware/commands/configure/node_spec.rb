# frozen_string_literal: true

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

RSpec.describe Underware::Commands::Configure::Node do
  def run_configure_node(node)
    Underware::Utils.run_command(
      Underware::Commands::Configure::Node, node
    )
  end

  let(:alces) { Underware::Namespaces::Alces.new }

  let(:test_group) do
    Underware::Namespaces::Group.new(initial_alces, 'testnodes', index: 1)
  end

  before do
    allow(Underware::Namespaces::Alces).to receive(:new).and_return(alces)
  end

  before :each do
    fs = Underware::Data
    fs.dump(Underware::FilePath.domain_answers, {})
    fs.dump(Underware::FilePath.group_answers('testnodes'), {})
  end

  it 'creates correct configurator' do
    expect(Underware::Configurator).to receive(:new).with(
      instance_of(Underware::Namespaces::Alces),
      questions_section: :node,
      name: 'testnode01'
    ).and_call_original

    run_configure_node 'testnode01'
  end
end
