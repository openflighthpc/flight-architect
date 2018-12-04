
# frozen_string_literal: true

require 'shared_examples/hash_merger_namespace'
require 'shared_examples/namespace_hash_merging'
require 'underware/namespaces/alces'

RSpec.describe Underware::Namespaces::Group do
  context 'with AlcesUtils' do
    include Underware::AlcesUtils

    context 'with mocked group' do
      subject { alces.groups.first }

      let(:test_group) { 'some_test_group' }

      Underware::AlcesUtils.mock self, :each do
        mock_group(test_group)
        mock_node('random_node', test_group)
      end

      include_examples Underware::Namespaces::HashMergerNamespace
    end

    context 'with a mocked genders file' do
      before do
        Underware::AlcesUtils.mock self do
          mock_group('group1')
          mock_group('group2')
        end

        genders = <<~EOF.strip_heredoc
        node[01-10]    group1,group2
        nodeA    group2
        EOF
        File.write Underware::FilePath.genders, genders
      end

      describe '#short_nodes_string' do
        it 'can find the hosts list' do
          group = alces.groups.find_by_name('group2')
          expect(group.hostlist_nodes).to eq('node[01-10],nodeA')
        end
      end
    end
  end

  describe 'hash merging' do
    subject do
      described_class.new(alces, 'testgroup', index: 1)
    end

    let :alces do
      Underware::Namespaces::Alces.new(platform: platform)
    end

    include_examples 'namespace_hash_merging',
      description: 'passes just `groups` containing own name',
      expected_hash_merger_input: {
        groups: ['testgroup'],
      }
  end
end
