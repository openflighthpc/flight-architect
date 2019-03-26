
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

require 'underware/command_helpers/alces_command'
require 'underware/spec/alces_utils'

RSpec.describe Underware::CommandHelpers::AlcesCommand do
  include Underware::AlcesUtils

  let(:domain_config) { Hash.new(key: 'I am the domain config') }

  let(:node) { 'node01' }
  let(:group) { 'group1' }

  Underware::AlcesUtils.mock self, :each do
    config(alces.domain, domain_config)
    mock_group(group)
    mock_node(node)
  end

  #
  # The purpose of the mixin is to provide the alces_command method
  # However as this is a private method, it has to use send
  #
  def test_command(command)
    double('TestDouble', alces: alces, raw_alces_command: command)
      .extend(Underware::CommandHelpers::AlcesCommand)
      .send(:alces_command)
  end

  it 'can return the domain config' do
    expect(test_command('alces.domain.config')).to eq(alces.domain.config)
  end

  it 'treats the leading alces as optional' do
    expect(test_command('domain.config')).to eq(alces.domain.config)
  end

  it 'allows short name for alces' do
    expect(test_command('a.domain.config')).to eq(alces.domain.config)
    expect(test_command('alc.domain.config')).to eq(alces.domain.config)
  end

  it 'allows short name for nodes' do
    expect(test_command("alces.n.#{node}.name")).to eq(node)
  end

  it 'allows short name for groups' do
    expect(test_command("alces.g.#{group}.name")).to eq(group)
  end

  it 'allows short name for domain' do
    expect(test_command('alces.d.config')).to eq(alces.domain.config)
  end
end
