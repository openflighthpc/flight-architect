
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
        xit 'can find the hosts list' do
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

    include_examples 'namespace_hash_merging',
      description: 'passes just `groups` containing own name',
      expected_hash_merger_input: {
        groups: ['testgroup'],
      }
  end
end
