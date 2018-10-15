
# frozen_string_literal: true

require 'namespaces/alces'
require 'constants'
require 'nodeattr_interface'

##
# NOTE: alces.nodes is an UnderwareArray
# However it is the behaviour of alces.nodes that needs to
# be ensured.
#
RSpec.describe Underware::Namespaces::UnderwareArray do
  let(:alces) { Underware::Namespaces::Alces.new }

  let(:node_names) { ['node1', 'node2', 'node3'] }

  before do
    allow(Underware::NodeattrInterface).to \
      receive(:all_nodes).and_return(node_names)
  end

  it 'has the correct number of items' do
    expect(alces.nodes.length).to eq(node_names.length)
  end

  it 'can find all the items' do
    node_names.each do |node|
      found_node = alces.nodes.send(node)
      expect(found_node.name).to eq(node)
    end
  end

  it 'can not be modified' do
    expect do
      alces.nodes.push('I should error')
    end.to raise_error(RuntimeError)
  end
end
