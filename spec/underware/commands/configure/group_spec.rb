# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
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

require 'underware/group_cache'
require 'underware/spec/alces_utils'

RSpec.describe Underware::Commands::Configure::Group do
  include Underware::AlcesUtils

  def run_configure_group(group)
    Underware::Utils.run_command(
      Underware::Commands::Configure::Group, group
    )
  end

  def update_cache
    Underware::GroupCache.update(alces.cluster_name) { |c| yield c }
  end

  def new_cache
    Underware::GroupCache.new(alces.cluster_name)
  end

  before do
    mock_validate_genders_success
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

        expect(new_cache.primary_groups).to eq [
          'testnodes',
          'orphan',
        ]
      end
    end

    context 'when `cache/groups.yaml` exists' do
      it 'inserts primary group if new' do
        update_cache { |c| c.add('first_group') }

        run_configure_group 'second_group'

        expect(new_cache.primary_groups).to eq [
          'first_group',
          'second_group',
          'orphan',
        ]
      end

      it 'does nothing if primary group already present' do
        ['first_group', 'second_group'].each do |group|
          update_cache { |c| c.add(group) }
        end

        run_configure_group 'second_group'

        expect(new_cache.primary_groups).to eq [
          'first_group',
          'second_group',
          'orphan',
        ]
      end
    end
  end
end
