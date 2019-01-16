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

require 'underware/data_path'

RSpec.describe Underware::DataPath do
  shared_examples 'generic path interface' do
    describe '#base' do
      it 'returns the dynamic base path' do
        expect(subject.base).to eq(base_path)
      end
    end

    describe '#relative' do
      let(:relative_path) { '/some/relative/path' }
      let(:absolute_path) { File.join(base_path, relative_path) }

      it 'returns the absolute path relative to the base path' do
        expect(subject.relative(relative_path)).to eq(absolute_path)
      end

      it 'wraps File.join' do
        expect(subject.relative(*relative_path.split('/'))).to eq(absolute_path)
      end
    end
  end

  context 'without a cluster' do
    let(:base_path) do
      File.join(Underware::Config.install_path, 'data')
    end
    subject { described_class.new }

    it_behaves_like 'generic path interface'
  end

  context 'with a cluster' do
    let(:cluster) { 'my-cluster' }
    let(:base_path) do
      File.join(Underware::Config.storage_path, 'clusters', cluster)
    end
    subject { described_class.new(cluster: cluster) }

    it_behaves_like 'generic path interface'
  end

  context 'with a specified base path' do
    let(:cluster) { 'this-cluster-should-be-ignored' }
    let(:base_path) { '/some/random/base/path' }
    subject { described_class.new(cluster: cluster, base: base_path) }

    it_behaves_like 'generic path interface'
  end
end
