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

require 'underware/spec/alces_utils'

RSpec.describe Underware::Commands::Configure::Group do
  include Underware::AlcesUtils

  def run_configure_group(group)
    Underware::Utils.run_command(
      Underware::Commands::Configure::Group, group, 'node[01-10]'
    )
  end

  def update_cache
    Underware::ClusterAttr.update(Underware::CommandConfig.load.current_cluster) do
      |a| yield a
    end
  end

  def new_cache
    Underware::ClusterAttr.load(Underware::CommandConfig.load.current_cluster)
  end

  before :each do
    FileSystem.setup(&:with_minimal_configure_file)
  end

  it 'creates correct configurator' do
    expect(Underware::Configurator).to receive(:new).with(
      instance_of(Underware::Namespaces::Alces),
      questions_section: :group,
      name: 'testnodes'
    ).and_call_original

    run_configure_group 'testnodes'
  end

  describe 'recording groups' do
    context 'when `cache/groups.yaml` does not exist' do
      it 'creates it and inserts new primary group' do
        run_configure_group 'testnodes'

        expect(new_cache.raw_groups).to contain_exactly *[
          'testnodes',
          'orphan',
        ]
      end
    end

    context 'with an existing unrelated group' do
      it 'inserts primary group if new' do
        update_cache { |c| c.add_group('firstgroup') }

        run_configure_group 'secondgroup'

        expect(new_cache.raw_groups).to contain_exactly *[
          'firstgroup',
          'secondgroup',
          'orphan',
        ]
      end

      it 'does nothing if primary group already present' do
        ['firstgroup', 'secondgroup'].each do |group|
          update_cache { |c| c.add_group(group) }
        end

        run_configure_group 'secondgroup'

        expect(new_cache.raw_groups).to contain_exactly *[
          'firstgroup',
          'secondgroup',
          'orphan',
        ]
      end
    end
  end
end
