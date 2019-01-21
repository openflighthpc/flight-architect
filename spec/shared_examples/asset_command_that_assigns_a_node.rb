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

require 'underware/spec/alces_utils'
require 'underware/cache/asset'

# Requires `asset_name` and `command_arguments` to be set by the
# calling spec
RSpec.shared_examples 'asset command that assigns a node' do
  include Underware::AlcesUtils

  # Stops the editor from running the bash command
  before { allow(Underware::Utils::Editor).to receive(:open) }

  let(:asset_cache) { Underware::Cache::Asset.new }
  let(:node_name) { 'test_node' }

  def run_command
    Underware::Utils.run_command(described_class,
                                 *command_arguments,
                                 node: node_name,
                                 stderr: StringIO.new)
  end

  context 'when the node is missing' do
    it 'raise an invalid input error' do
      expect { run_command }.to raise_error(Underware::InvalidInput)
    end
  end

  context 'when the node exists' do
    let!(:node) { Underware::AlcesUtils.mock(self) { mock_node(node_name) } }

    it 'assigns the asset to the node' do
      run_command
      expect(asset_cache.asset_for_node(node)).to eq(asset_name)
    end
  end
end
