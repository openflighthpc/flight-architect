# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Metalware.
#
# Alces Metalware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Metalware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Metalware, please visit:
# https://github.com/alces-software/metalware
#==============================================================================

require 'commands/each'
require 'spec_utils'
require 'ostruct'
require 'hash_mergers'
require 'namespaces/alces'

RSpec.describe Metalware::Commands::Each, real_fs: true do
  before :each do
    SpecUtils.use_mock_genders(self)
    SpecUtils.use_unit_test_config(self)
  end

  let :config { Metalware::Config.new }
  let :alces do
    a = Metalware::Namespaces::Alces.new(config)
    allow(Metalware::Namespaces::Alces).to receive(:new).and_return(a)
    a
  end
  let :groups do
    g = Metalware::Namespaces::Group.new(alces, 'nodes', index: 1)
    Metalware::Namespaces::MetalArray.new([g])
  end

  # Spoofs the nodes group
  before :each do
    allow(alces).to receive(:groups).and_return(groups)
  end

  # Turns off loading of answers as they are not needed
  before :each do
    allow(Metalware::HashMergers::Answer).to \
      receive(:new).and_return(double('answer', merge: {}))
  end

  def run_command_echo(node, group = false)
    opt = OpenStruct.new(group: group)
    $stdout = tmp = Tempfile.new('stdout')
    Metalware::Commands::Each.new([node, 'echo <%= node.name %>'], opt)
    $stdout.flush
    $stdout.rewind
    $stdout.read
  ensure
    tmp.delete if tmp.respond_to?(:delete)
    $stdout = STDOUT
  end

  it 'runs the command on a single node' do
    output = run_command_echo('node01')
    expect(output).to eq("node01\n")
  end

  it 'runs the command over a group' do
    expected = (1..3).inject('') { |str, num| "#{str}testnode0#{num}\n" }
    output = run_command_echo('nodes', true)
    expect(output).to eq(expected)
  end
end
