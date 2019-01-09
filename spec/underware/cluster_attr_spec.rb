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

require 'underware/cluster_attr'

RSpec.describe Underware::ClusterAttr do
  shared_context 'with a ClusterAttr instance' do
    let(:cluster_name) { 'my-test-cluster' }
    subject { described_class.new(cluster_name) }
  end

  shared_context 'with the first group' do
    let(:first_group) { 'my-first-group' }
    before { subject.add_group(first_group) }
  end

  describe '::expand' do
    it 'can expand multiple nodes' do
      node_str = 'node[01-10]'
      nodes = (1...10).map { |i| "node0#{i}" }
                      .push('node10')
      expect(described_class.expand(node_str)).to contain_exactly(*nodes)
    end
  end

  context 'without any additional groups' do
    include_context 'with a ClusterAttr instance'

    describe '#raw_groups' do
      it 'contains the orphan group' do
        expect(subject.raw_groups).to include('orphan')
      end
    end

    describe '#group_index' do
      it 'returns nil for missing groups' do
        expect(subject.group_index('some-missing-group')).to eq(nil)
      end

      it 'returns 0 for the orphan group' do
        expect(subject.group_index('orphan')).to eq(0)
      end
    end
  end

  context 'when adding a single group' do
    include_context 'with a ClusterAttr instance'
    include_context 'with the first group'

    describe '#add_group' do
      it 'errors when adding an existing group' do
        expect do
          subject.add_group(first_group)
        end.to raise_error(Underware::ExistingGroupError)
      end
    end

    describe '#raw_groups' do
      it 'contains the group' do
        expect(subject.raw_groups).to include(first_group)
      end
    end

    describe '#raw_nodes' do
      it 'returns and empty array' do
        expect(subject.raw_nodes).to eq([])
      end
    end

    describe '#group_index' do
      it 'returns 1 for the first group' do
        expect(subject.group_index(first_group)).to eq(1)
      end
    end
  end

  context 'when adding nodes' do
    include_context 'with a ClusterAttr instance'

    let(:node_str) { 'node[01-10]' }
    let(:nodes) { described_class.expand(node_str) }
    let(:node_groups) { nil }

    before do
      if node_groups
        subject.add_nodes(node_str, groups: node_groups)
      else
        subject.add_nodes(node_str)
      end
    end

    describe '#add_nodes' do
      it 'errors if a node is re-added' do
        expect do
          subject.add_nodes(node_str)
        end.to raise_error(Underware::ExistingNodeError)
      end
    end

    context 'without any groups' do
      describe '#raw_nodes' do
        it 'returns the node list' do
          expect(subject.raw_nodes).to contain_exactly(*nodes)
        end
      end

      describe '#groups_for_node' do
        it 'returns an empty array' do
          expect(subject.groups_for_node(nodes.first)).to eq([])
        end
      end
    end

    context 'when adding them to the first group' do
      include_context 'with the first group'

      let(:node_groups) { first_group }

      describe '#groups_for_node' do
        it 'returns an array of the group' do
          expect(subject.groups_for_node(nodes.first)).to contain_exactly(first_group)
        end
      end
    end

    context 'when adding multiple missing groups' do
      let(:node_groups) { ['missing1', 'missing2'] }

      describe '#groups_for_node' do
        it 'returns the missing groups in the correct order' do
          expect(subject.groups_for_node(nodes.last)).to eq(node_groups)
        end
      end
    end
  end
end
