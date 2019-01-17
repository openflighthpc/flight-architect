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

require 'underware/data_copy'
require 'pathname'

RSpec.describe Underware::DataCopy do
  shared_context 'with existing cluster1 files' do
    let(:cluster1_path) { Underware::DataPath.new(cluster: 'cluster1') }
    let(:cluster1_files) do
      [
        'file1',
        ['directory', 'file2'],
        ['directory', 'sub-directory', 'file3']
      ].map { |p| cluster1_path.relative(*p) }
    end

    before do
      cluster1_files.each do |path|
        FileUtils.mkdir_p(File.dirname(path))
        FileUtils.touch(path)
      end
    end
  end

  shared_context 'with a non-existant new cluster' do
    let(:new_cluster) { 'new-cluster' }
    let(:new_cluster_path) { Underware::DataPath.new(cluster: new_cluster) }
  end

  context 'when copying to a non existant cluster' do
    include_context 'with existing cluster1 files'
    include_context 'with a non-existant new cluster'

    let(:new_paths) do
      base = Pathname.new(cluster1_path.base)
      cluster1_files.map { |p| Pathname.new(p).relative_path_from(base).to_s }
                    .map { |p| File.expand_path(p, new_cluster_path.base) }
    end
    subject do
      described_class.new(cluster1_path, new_cluster_path)
    end

    describe '#all' do
      before { subject.all }

      it 'copyies all the files into the new clusters directory' do
        new_paths.each { |p| expect(Pathname.new(p)).to be_exist }
      end
    end
  end
end
