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
  def touch_file(path)
    FileUtils.mkdir_p(File.dirname(path))
    FileUtils.touch(path)
  end

  def expect_path(path)
    expect(Pathname.new(path))
  end

  shared_context 'with base files' do
    let(:join_base_files) { ['base-file1', 'base-file2'] }
    let(:base_path) { Underware::DataPath.new }
    before do
      join_base_files.each { |p| touch_file(base_path.join(p)) }
    end
  end

  shared_context 'with existing cluster1 files' do
    let(:cluster1_path) { Underware::DataPath.cluster('cluster1') }
    let(:join_cluster1_files) do
      [
        'file1',
        'directory/file2',
        'directory/sub-directory/file3'
      ]
    end
    let(:cluster1_files) do
      join_cluster1_files.map { |p| cluster1_path.join(p) }
    end

    before { cluster1_files.each { |p| touch_file(p) } }
  end

  shared_context 'with an existing layout' do
    let(:layout) { 'my-layout' }
    let(:layout_path) { Underware::DataPath.layout(layout) }
    let(:join_layout_files) { ['file1', 'directory/file2'] }

    before do
      join_layout_files.each do |rel_path|
        touch_file(layout_path.join(rel_path))
      end
    end
  end

  shared_context 'with a non-existant new cluster' do
    let(:new_cluster) { 'new-cluster' }
    let(:new_cluster_path) { Underware::DataPath.new(cluster: new_cluster) }
  end

  shared_examples 'copy to new cluster' do
    it 'copies the files to the new cluster' do
      expect_join_copied_files.each do |rel_path|
        expect_path(new_cluster_path.join(rel_path)).to be_exist
      end
    end
  end

  context 'when copying to a non existant cluster' do
    include_context 'with existing cluster1 files'
    include_context 'with a non-existant new cluster'

    let(:new_paths) do
      base = Pathname.new(cluster1_path.base)
      cluster1_files.map { |p| Pathname.new(p).join_path_from(base).to_s }
                    .map { |p| File.expand_path(p, new_cluster_path.base) }
    end
    subject do
      described_class.new(cluster1_path, new_cluster_path)
    end

    describe '#all' do
      let(:expect_join_copied_files) { join_cluster1_files }
      before { subject.all }

      include_examples 'copy to new cluster'
    end
  end

  describe '::layout_to_cluster' do
    shared_examples 'a layout cluster generator' do
      include_context 'with a non-existant new cluster'
      subject do
        described_class.layout_to_cluster(subject_layout, new_cluster)
      end

      describe '#all' do
        before { subject.all }
        include_examples 'copy to new cluster'
      end
    end

    shared_examples 'a protected copy' do
      # The `nil` cluster also corresponds to the base layout. There should
      # be no way to copy to the base section through `layout_to_cluster`
      # Similarly, it shouldn't be able to write to the empty string cluster
      ['', nil, false].each do |dst|
        it "errors when copying to the #{dst.inspect} cluster" do
          expect do
            described_class.layout_to_cluster(subject_layout, dst)
          end.to raise_error(Underware::InternalError)
        end
      end
    end

    context 'when the from the nil (aka base) layout' do
      include_context 'with base files'
      let(:subject_layout) { nil }
      let(:expect_join_copied_files) { join_base_files }

      it_behaves_like 'a layout cluster generator'
      it_behaves_like 'a protected copy'
    end

    context 'when copying from a layout' do
      include_context 'with an existing layout'
      let(:subject_layout) { layout }
      let(:expect_join_copied_files) { join_layout_files }

      it_behaves_like 'a layout cluster generator'
      it_behaves_like 'a protected copy'
    end
  end

  describe '::init_cluster' do
    shared_examples 'a standard init' do
      include_context 'with base files'
      include_context 'with a non-existant new cluster'
      let(:expect_join_copied_files) { join_base_files }

      before do
        described_class.init_cluster(new_cluster, layout: subject_layout)
      end

      include_examples 'copy to new cluster'
    end

    let(:subject_layout) { nil }

    context 'when copying to a new cluster' do
      it_behaves_like 'a standard init'
    end

    context 'with a layout as part of the init' do
      include_context 'with an existing layout'
      let(:subject_layout) { layout }

      it_behaves_like 'a standard init'

      context 'with layout files' do
        include_context 'with a non-existant new cluster'
        let(:expect_join_copied_files) { join_layout_files }

        before do
          described_class.init_cluster(new_cluster, layout: subject_layout)
        end
        include_examples 'copy to new cluster'
      end
    end
  end
end
