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

RSpec.shared_examples 'namespace_hash_merging' do |args|
  base_description = args.fetch(:description)
  base_expected_hash_merger_input = args.fetch(:expected_hash_merger_input)

  let(:alces) do
    Underware::Namespaces::Alces.new(platform: platform)
  end

  shared_examples 'calls hash mergers correctly' do |local_args|
    description = local_args.fetch(:description)

    let(:expected_hash_merger_input) do
      local_args.fetch(:expected_hash_merger_input)
    end

    it "#{description}, to Config HashMerger" do
      expect(alces.hash_mergers.config).to receive(:merge).with(
        expected_hash_merger_input
      )

      subject.config
    end

    it "#{description}, to Answer HashMerger" do
      expect(alces.hash_mergers.answer).to receive(:merge).with(
        expected_hash_merger_input
      )

      subject.answer
    end
  end

  context 'when no platform passed' do
    let(:platform) { nil }

    include_examples 'calls hash mergers correctly',
      description: base_description,
      expected_hash_merger_input: base_expected_hash_merger_input
  end

  context 'when platform passed' do
    let(:platform) { 'my_platform' }

    include_examples 'calls hash mergers correctly',
      description: "#{base_description}, with platform as a symbol",
      expected_hash_merger_input:
        base_expected_hash_merger_input.merge(platform: :my_platform)
  end
end
