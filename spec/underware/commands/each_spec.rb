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

require 'underware/commands/each'
require 'ostruct'
require 'underware/hash_mergers'
require 'underware/namespaces/alces'

RSpec.describe Underware::Commands::Each do
  include Underware::AlcesUtils

  before do
    FileSystem.root_setup do |fs|
      fs.with_genders_fixtures
      fs.with_clone_fixture('configs/unit-test.yaml')
    end
  end

  let(:groups) do
    g = Underware::Namespaces::Group.new(alces, 'nodes', index: 1)
    Underware::Namespaces::UnderwareArray.new([g])
  end

  # Spoofs the nodes group
  before do
    allow(alces).to receive(:groups).and_return(groups)
  end

  # Turns off loading of answers as they are not needed
  before do
    allow(Underware::HashMergers::Answer).to \
      receive(:new).and_return(double('answer', merge: {}))
  end

  def run_command_echo(node, gender = false)
    FakeFS.deactivate!
    opt = OpenStruct.new(gender: gender)
    file = Tempfile.new
    file.close
    cmd = "echo <%= node.name %> >> #{file.path}"
    FakeFS.with do
      Underware::Commands::Each.new([node, cmd], opt)
    end
    File.read(file.path)
  ensure
    file.unlink
    FakeFS.activate!
  end

  it 'runs the command on a single node' do
    output = run_command_echo('node01')
    expect(output).to eq("node01\n")
  end

  it 'runs the command over a gender' do
    expected = (1..3).inject('') { |str, num| "#{str}testnode0#{num}\n" }
    output = run_command_echo('nodes', true)
    expect(output).to eq(expected)
  end
end