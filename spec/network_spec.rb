
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
