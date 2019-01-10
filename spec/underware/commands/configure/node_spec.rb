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

RSpec.describe Underware::Commands::Configure::Node do
  def run_configure_node(node)
    Underware::Utils.run_command(
      Underware::Commands::Configure::Node, node
    )
  end

  let(:alces) { Underware::Namespaces::Alces.new }

  let(:test_group) do
    Underware::Namespaces::Group.new(initial_alces, 'testnodes', index: 1)
  end

  before do
    allow(Underware::Namespaces::Alces).to receive(:new).and_return(alces)
  end

  before :each do
    FileSystem.setup do |fs|
      fs.with_minimal_configure_file
      fs.dump(Underware::FilePath.domain_answers, {})
      fs.dump(Underware::FilePath.group_answers('testnodes'), {})
    end
  end

  it 'creates correct configurator' do
    expect(Underware::Configurator).to receive(:new).with(
      instance_of(Underware::Namespaces::Alces),
      questions_section: :node,
      name: 'testnode01'
    ).and_call_original

    run_configure_node 'testnode01'
  end
end
