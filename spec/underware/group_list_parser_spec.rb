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

require 'underware/group_list_parser'

RSpec.describe Underware::GroupListParser do
  describe '::parse' do
    it 'converts nil to an empty array' do
      expect(described_class.parse(nil)).to eq([])
    end

    it 'handles blank values within the list' do
      expect(described_class.parse(',,,')).to eq([])
    end

    it 'returns the list of groups' do
      groups = ['group', 'differentgroup', 'group4', 'agroup1']
      expect(described_class.parse(groups.join(','))).to eq(groups)
    end

    it 'errors if a group is repeated' do
      expect do
        expect(described_class.parse('group,group'))
      end.to raise_error(Underware::RepeatedGroupError)
    end

    context 'with non alphanumeric characters' do
      ['_', '-', '!', '*', '.'].each do |char|
        it "errors with: #{char}" do
          str = "group#{char}"
          expect do
            described_class.parse(str)
          end.to raise_error(Underware::InvalidGroupName)
        end
      end
    end
  end
end
