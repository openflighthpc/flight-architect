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

require 'underware/commands'
require 'fixtures/shared_context/overview'
require 'underware/data_copy'

RSpec.describe Underware::Commands::Overview do
  include_context 'overview context'

  let(:name_hash) { { header: 'Group Name', value: '<%= group.name %>' } }

  def run_command
    Underware::AlcesUtils.redirect_std(:stdout) do
      Underware::Utils.run_command(Underware::Commands::Overview)
    end
  end

  before do
    allow(Underware::Overview::Table).to \
      receive(:new).with(any_args).and_call_original
  end

  def expect_table_with(*inputs)
    expect(Underware::Overview::Table).to \
      receive(:new).once.with(*inputs).and_call_original
  end

  it 'does not error when using the real overview.yaml' do
    Underware::DataCopy.init_cluster(Underware::CommandConfig.load.current_cluster)
    expect do
      run_command
    end.not_to raise_error
  end

  # We create an `overview.yaml` file just for testing:
  # a. for legacy reasons, as this file uses to live in the repo and so be
  # unavailable in tests;
  # b. so engineers can edit the real file as needed without breaking these
  # tests.
  context 'with a test-specific overview.yaml' do
    let(:overview_hash) do
      {
        domain: [{ header: 'h1', value: 'v1' }, { header: 'h2', value: 'v2' }],
        group: fields,
      }
    end

    before do
      Underware::Data.dump Underware::FilePath.overview, overview_hash
    end

    it 'includes the group name and additional fields' do
      combined_fields = [name_hash].concat fields
      expect_table_with alces.groups, combined_fields
      run_command
    end

    it 'includes the additional domain table fields' do
      expect_table_with [alces.domain], overview_hash[:domain]
      run_command
    end
  end
end
