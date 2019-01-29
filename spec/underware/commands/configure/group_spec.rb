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
