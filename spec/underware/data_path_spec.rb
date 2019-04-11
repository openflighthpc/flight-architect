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

require 'underware/data_path'

RSpec.describe Underware::DataPath do
  shared_examples 'generic path interface' do
    describe '#base' do
      it 'returns the dynamic base path' do
        expect(subject.base.to_s).to eq(base_path)
      end
    end

    describe '#join' do
      let(:join_path) { '/some/join/path' }
      let(:absolute_path) { File.join(base_path, join_path) }

      it 'returns the absolute path join to the base path' do
        expect(subject.join(join_path).to_s).to eq(absolute_path)
      end

      it 'wraps File.join' do
        expect(subject.join(*join_path.split('/')).to_s).to eq(absolute_path)
      end
    end
  end

  context 'without a cluster' do
    let(:base_path) do
      File.join(Underware::Config.install_path, 'data/base')
    end
    subject { described_class.new }

    it_behaves_like 'generic path interface'
  end

  context 'with a specified overlay path' do
    let(:overlay) { 'my-overlay' }
    let(:base_path) do
      File.join(Underware::Config.install_path, 'data', overlay)
    end
    subject { described_class.new(overlay: overlay) }

    it_behaves_like 'generic path interface'
  end

  context 'with a cluster' do
    let(:cluster) { 'my-cluster' }
    let(:overlay) { 'this-overlay-should-be-ignored' }
    let(:base_path) do
      File.join(Underware::Config.storage_path, 'clusters', cluster)
    end
    subject { described_class.new(cluster: cluster, overlay: overlay) }

    it_behaves_like 'generic path interface'
  end

  context 'with a specified base path' do
    let(:cluster) { 'this-cluster-should-be-ignored' }
    let(:overlay) { 'this-overlay-should-be-ignored' }
    let(:base_path) { '/some/random/base/path' }
    subject do
      described_class.new(cluster: cluster, base: base_path, overlay: overlay)
    end

    it_behaves_like 'generic path interface'
  end
end
