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

RSpec.describe Underware::GroupCache do
  include Underware::AlcesUtils

  let(:cluster_name) { 'my-cluster' }
  let(:cache) { new_cache }

  def new_cache
    Underware::GroupCache.new(cluster_name)
  end

  before :each do
    FileSystem.setup do |fs|
      fs.with_group_cache_fixture('cache/groups.yaml')
    end
  end

  describe '#group?' do
    it 'checks if a group has been configured' do
      expect(cache.group?('testnodes')).to eq(true)
      expect(cache.group?('missing_group')).to eq(false)
    end
  end

  describe '#add' do
    it 'adds a new group' do
      expect(cache.group?('new_group')).to eq(false)
      cache.add('new_group')
      expect(cache.group?('new_group')).to eq(true)

      next_available_index = 3
      expect(cache.index('new_group')).to eq(next_available_index)
    end

    it 'increments the group index' do
      expect(cache.group?('new_group1')).to eq(false)
      expect(cache.group?('new_group2')).to eq(false)
      cache.add('new_group1')
      cache.add('new_group2')
      expect(cache.index('new_group1') + 1).to eq(cache.index('new_group2'))
    end

    it 'ignores groups that have already been added' do
      expect(cache.group?('testnodes')).to eq(true)
      number_groups = cache.primary_groups.length
      cache.add('testnodes')
      expect(cache.primary_groups.length).to eq(number_groups)
    end
  end

  describe '#remove' do
    it 'removes a group' do
      expect(cache.group?('testnodes')).to eq(true)
      static_index_of_other_group = cache.index('testnodes')

      expect(cache.group?('some_group')).to eq(true)
      cache.remove('some_group')
      expect(cache.group?('some_group')).to eq(false)

      expect(cache.index('testnodes')).to eq(static_index_of_other_group)
    end
  end

  describe '#index' do
    it 'preserves incrementing index as groups are added/removed' do
      group1 = 'group1'
      cache.add(group1)
      expect(cache.index(group1)).to eq 3

      cache.remove(group1)

      group2 = 'group2'
      cache.add(group2)
      expect(cache.index(group2)).to eq 4
    end
  end

  describe '#primary_groups' do
    it 'gives list with just orphan group by default' do
      FileUtils.rm Underware::FilePath.group_cache

      expect(cache.primary_groups).to eq(['orphan'])
    end

    it 'gives list with just orphan group if cache already exists without next_available_index' do
      File.write(Underware::FilePath.group_cache, "some_junk: doesn't matter")

      expect(cache.primary_groups).to eq(['orphan'])
    end
  end

  describe '#next_available_index' do
    it 'gives 1 by default' do
      FileUtils.rm Underware::FilePath.group_cache

      expect(cache.next_available_index).to eq(1)
    end

    it 'gives 1 if cache already exists without next_available_index' do
      File.write(Underware::FilePath.group_cache, "some_junk: doesn't matter")

      expect(cache.next_available_index).to eq(1)
    end
  end

  describe '#orphans' do
    it 'gives empty list by default' do
      expect(cache.orphans).to eq([])
    end

    it 'gives empty list if cache already exists without orphans' do
      File.write(Underware::FilePath.group_cache, "some_junk: doesn't matter")

      expect(cache.orphans).to eq([])
    end
  end

  describe '#add_orphan' do
    it 'adds the orphans' do
      orphans = ['node1', 'node2', 'node3']
      orphans.each do |orphan|
        cache.push_orphan(orphan)
      end
      cache.save
      expect(new_cache.orphans).to eq(orphans)
    end

    it 'silently refuses to double add orphans' do
      orphan = 'node1'
      cache.push_orphan(orphan)
      cache.push_orphan(orphan)
      cache.save
      expect(new_cache.orphans).to eq([orphan])
    end
  end

  describe '#update' do
    it 'yields the group cache' do
      described_class.update(cluster_name) do |cache|
        expect(cache).to be_a(described_class)
      end
    end

    it 'does not save if there is an error' do
      group = 'my-new-group'
      expect do
        described_class.update(cluster_name) do |cache|
          cache.add group
          raise 'something has gone wrong'
        end
      end.to raise_error(RuntimeError)
      expect(described_class.new(cluster_name).group?(group)).to eq false
    end
  end
end
