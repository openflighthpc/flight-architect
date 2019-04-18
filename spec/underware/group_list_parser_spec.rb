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
