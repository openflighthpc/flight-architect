
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

require 'underware/namespaces/alces'
require 'underware/constants'
require 'underware/cluster_attr'

##
# NOTE: alces.nodes is an UnderwareArray
# However it is the behaviour of alces.nodes that needs to
# be ensured.
#
RSpec.describe Underware::Namespaces::UnderwareArray do
  let(:alces) { Underware::Namespaces::Alces.new }

  let(:node_names) { ['node1', 'node2', 'node3'] }

  before do
    Underware::ClusterAttr.update(Underware::CommandConfig.load.current_cluster) do |attr|
      node_names.each { |node| attr.add_nodes(node) }
    end
  end

  it 'has the correct number of items' do
    expect(alces.nodes.length).to eq(node_names.length)
  end

  it 'can find all the items' do
    node_names.each do |node|
      found_node = alces.nodes.send(node)
      expect(found_node.name).to eq(node)
    end
  end

  it 'can not be modified' do
    expect do
      alces.nodes.push('I should error')
    end.to raise_error(RuntimeError)
  end
end
