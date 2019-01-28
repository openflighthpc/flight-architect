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

    it 'can expand a single node' do
      node = 'node01'
      expect(described_class.expand(node)).to contain_exactly(node)
    end
  end

  describe '::update' do
    include_context 'with a ClusterAttr instance'

    let(:path) { subject.path }

    context 'when called with a block' do
      before { described_class.update(subject.cluster) {} }

      it 'writes the file if it does not exist' do
        expect(File.exists?(path)).to be true
      end
    end

    context 'when called without a block' do
      before { described_class.update(subject.cluster) }

      it 'does not write the file' do
        expect(File.exists?(path)).to be false
      end
    end

    it 'returns the instance' do
      expect(described_class.update(subject.cluster)).to be_a(described_class)
    end

    it 'updates the config for future reference' do
      new_group = 'my-new-group'
      described_class.update(subject.cluster) { |a| a.add_group(new_group) }
      expect(described_class.load(subject.cluster).raw_groups).to include(new_group)
    end

    context 'with an existing group' do
      include_context 'with a ClusterAttr instance'
      include_context 'with the first group'

      before { Underware::ConfigLoader.write(subject) }

      it 'preserves the existing data' do
        new_attr = described_class.update(subject.cluster)
        expect(new_attr.raw_groups).to eq(subject.raw_groups)
      end
    end
  end

  context 'without any additional groups or nodes' do
    include_context 'with a ClusterAttr instance'

    describe '#raw_groups' do
      it 'contains the orphan group' do
        expect(subject.raw_groups).to include('orphan')
      end
    end

    describe '#remove_group' do
      it 'does nothing' do
        expect do
          subject.remove_group('missing')
        end.not_to raise_error
      end

      it 'errors when deleting the orphan group' do
        expect do
          subject.remove_group('orphan')
        end.to raise_error(Underware::ClusterAttrError)
      end
    end

    describe '#remove_nodes' do
      it 'does nothing' do
        expect do
          subject.remove_nodes('missing[1-10]')
        end.not_to raise_error
      end
    end

    describe '#nodes_list' do
      it 'is initially an empty array' do
        expect(subject.nodes_list).to eq([])
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

    describe '#orphans' do
      it 'is initially an empty array' do
        expect(subject.orphans).to eq([])
      end
    end

    describe '#nodes_in_group' do
      it 'returns an empty array when there are no nodes' do
        expect(subject.nodes_in_group('some-random-group')).to eq([])
      end
    end

    describe '#path' do
      it 'returns a cluster path' do
        base = Underware::DataPath.cluster(subject.cluster).base
        expect(subject.path).to match(/#{base}.*\.yaml/)
      end
    end
  end

  context 'when adding a single group' do
    include_context 'with a ClusterAttr instance'
    include_context 'with the first group'

    describe '#add_group' do
      let!(:original_index) { subject.group_index(first_group) }

      before do
        # Adds another group to make the spec more realistic
        subject.add_group('some-other-group')

        # Ensure the original_index is set
        original_index
        subject.add_group(first_group)
      end

      it 'does not re add the group' do
        expect(subject.raw_groups.count(first_group)).to eq(1)
      end

      it 'does not change the index' do
        expect(subject.group_index(first_group)).to eq(original_index)
      end
    end

    describe '#remove_group' do
      let(:second_group) { 'my-second-group' }
      let!(:second_group_index) {}
      let(:first_node) { 'first_group_node' }
      let(:second_node) { 'second_group_node' }

      before do
        subject.add_nodes(first_node, groups: [first_group, second_group])
        subject.add_nodes(second_node, groups: [second_group, first_group])
      end

      it 'preserves latter groups index' do
        original_index = subject.group_index(second_group)
        subject.remove_group(first_group)
        expect(subject.group_index(second_group)).to eq(original_index)
      end

      context 'with the first group removed' do
        before { subject.remove_group(first_group) }

        it 'removes the group' do
          expect(subject.raw_groups).not_to include(first_group)
        end

        it 'removes the groups primary nodes' do
          expect(subject.nodes_list).not_to include(first_node)
        end

        it 'does not remove the secondary nodes' do
          expect(subject.nodes_list).to include(second_node)
        end

        describe '#groups_hash' do
          it 'does not include nil as a key' do
            expect(subject.groups_hash.keys).not_to include(nil)
          end
        end

        describe '#group_index' do
          it 'returns nil for the nil group' do
            expect(subject.group_index(nil)).to be(nil)
          end
        end
      end
    end

    describe '#raw_groups' do
      it 'contains the group' do
        expect(subject.raw_groups).to include(first_group)
      end
    end

    describe '#group_index' do
      it 'returns 1 for the first group' do
        expect(subject.group_index(first_group)).to eq(1)
      end
    end

    describe '#groups_hash' do
      it 'returns key-value pairs of names to indices' do
        expect(subject.groups_hash).to include(first_group => 1, 'orphan' => 0)
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
      let(:new_groups) { ['new_group1', 'new_group2'] }
      before { subject.add_nodes(node_str, groups: new_groups) }

      it 'does not duplicate the node entry' do
        expect(subject.nodes_list.count(nodes.first)).to eq(1)
      end

      it 'updates the groups entry' do
        expect(subject.groups_for_node(nodes.first)).to eq(new_groups)
      end

      it 'implicitly adds the primary group' do
        expect(subject.groups_hash.keys).to include(new_groups.first)
        expect(subject.groups_hash.keys).not_to include(new_groups.last)
      end
    end

    describe '#remove_nodes' do
      before { subject.add_nodes(node_str) }

      it 'can remove a single node only' do
        delete_node = nodes.shift
        subject.remove_nodes(delete_node)
        expect(subject.nodes_list).not_to include(delete_node)
        expect(subject.nodes_list).to include(*nodes)
      end

      it 'can remove a range of nodes' do
        subject.remove_nodes(node_str)
        expect(subject.nodes_list).not_to include(*nodes)
      end
    end

    context 'without any groups' do
      describe '#nodes_list' do
        it 'returns the node list' do
          expect(subject.nodes_list).to contain_exactly(*nodes)
        end
      end

      describe '#groups_for_node' do
        it 'is placed in the orphan group' do
          expect(subject.groups_for_node(nodes.first)).to eq(['orphan'])
        end
      end

      describe '#orphans' do
        it 'includes the nodes' do
          expect(subject.orphans).to contain_exactly(*nodes)
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
          expect(subject.groups_for_node(nodes.first)).to eq(node_groups)
        end
      end
    end
  end

  context 'when adding multiple nodes' do
    include_context 'with a ClusterAttr instance'
    let(:group1_nodes) { ['node1', 'node2', 'node4'] }

    # Other nodes are injected in to make the example more realistic
    before do
      group1_nodes.each do |node|
        subject.add_nodes(node, groups: 'group1')
        subject.add_nodes("not_#{node}")
      end
    end

    describe '#nodes_in_group' do
      it 'returns a specific group of nodes' do
        expect(subject.nodes_in_group('group1')).to eq(group1_nodes)
      end
    end
  end
end
