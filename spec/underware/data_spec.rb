
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

require 'underware/data'

RSpec.describe Underware::Data do
  let(:data_file_path) { '/path/to/some_data.yaml' }

  let(:string_keyed_data) do
    {
      'a_key' => 'foo',
      'another_key' => {
        'nested' => 'bar',
      },
    }
  end

  let(:symbol_keyed_data) do
    {
      a_key: 'foo',
      another_key: {
        nested: 'bar',
      },
    }
  end

  let(:invalid_yaml) { '[half an array' }

  before :each do
    FileUtils.mkdir_p(File.dirname(data_file_path))
  end

  describe '#load' do
    subject { described_class.load(data_file_path) }

    it 'loads the data file and recursively converts all keys to symbols' do
      File.write(data_file_path, YAML.dump(string_keyed_data))

      expect(subject).to eq(symbol_keyed_data)
    end

    it 'returns {} if the file is empty' do
      FileUtils.touch(data_file_path)

      expect(subject).to eq({})
    end

    it 'returns {} if the file does not exist' do
      expect(subject).to eq({})
    end

    it 'raises if the file contains invalid YAML' do
      File.write(data_file_path, invalid_yaml)

      expect { subject }.to raise_error Psych::SyntaxError
    end

    it 'raises if loaded file does not contain hash' do
      array = ['foo', 'bar']
      File.write(data_file_path, YAML.dump(array))

      expect { subject }.to raise_error(Underware::DataError)
    end
  end

  describe '#dump' do
    it 'dumps the data to the data file with all keys as strings' do
      described_class.dump(data_file_path, symbol_keyed_data)

      expect(
        YAML.load_file(data_file_path)
      ).to eq(string_keyed_data)
    end

    it 'raises if attempt to dump non-hash data' do
      expect do
        described_class.dump(data_file_path, ['foo', 'bar'])
      end.to raise_error(Underware::DataError)
    end
  end
end
