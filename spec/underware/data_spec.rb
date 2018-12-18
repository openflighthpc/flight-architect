
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
    FileSystem.setup do |fs|
      fs.mkdir_p(File.dirname(data_file_path))
    end
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
