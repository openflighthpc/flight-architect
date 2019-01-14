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

require 'underware/namespaces/node_prototype'

RSpec.describe Underware::Namespaces::NodePrototype do
  include Underware::AlcesUtils

  context 'without a genders input into initialize' do
    subject { described_class.new(alces) }

    describe '#genders' do
      it 'returns and empty array' do
        expect(subject.genders).to eq([])
      end
    end
  end

  context 'with a genders input into initialize' do
    let(:genders) { ['group1', 'group2'] }
    subject { described_class.new(alces, genders: genders) }

    describe '#genders' do
      it 'returns the genders' do
        expect(subject.genders).to eq(genders)
      end
    end
  end
end
