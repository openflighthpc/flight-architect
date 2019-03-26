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

RSpec.describe Underware::Network do
  describe '#available_interfaces' do
    it 'returns all interface names, minus loopback, sorted' do
      allow(NetworkInterface).to receive(:interfaces).and_return([
        'eth1', 'eth0', 'lo', 'eth2'
      ])

      expect(
        described_class.available_interfaces
      ).to eq(['eth0', 'eth1', 'eth2'])
    end

    it 'raises if no interfaces that we want to consider available' do
      allow(NetworkInterface).to receive(:interfaces).and_return(['lo'])

      expect{
        described_class.available_interfaces
      }.to raise_error(Underware::NoNetworkInterfacesAvailable)
    end
  end
end
