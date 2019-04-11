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
