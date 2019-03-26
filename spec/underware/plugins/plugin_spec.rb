
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

RSpec.describe Underware::Plugins::Plugin do
  subject { described_class.new(plugin_dir_path) }

  let(:plugin_dir_path) { Pathname.new('/path/to/some-plugin') }

  describe '#enabled_question_identifier' do
    it 'gives correct identifier for generated plugin enabled question' do
      expect(
        subject.enabled_question_identifier
      ).to eq 'underware_internal--plugin_enabled--some-plugin'
    end
  end

  it 'gives correct path for each path method' do
    expect(
      subject.domain_config.to_s
    ).to eq("#{plugin_dir_path}/etc/configs/domain.yaml")
    expect(
      subject.group_config('some_group').to_s
    ).to eq("#{plugin_dir_path}/etc/configs/groups/some_group.yaml")
    expect(
      subject.node_config('some_node').to_s
    ).to eq("#{plugin_dir_path}/etc/configs/nodes/some_node.yaml")
  end
end
