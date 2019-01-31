
# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2019 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Underware.
#
# Alces Underware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Underware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Underware, please visit:
# https://github.com/alces-software/underware
#==============================================================================

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
