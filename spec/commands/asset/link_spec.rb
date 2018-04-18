# frozen_string_literal: true

require 'alces_utils'
require 'cache/asset'
require 'filesystem'

RSpec.describe Metalware::Commands::Asset::Link do
  include AlcesUtils

  let :asset_name { 'asset_test' }
  let :node_name { 'test_node' }
  let :node { alces.nodes.find_by_name(node_name) }
  let :content { { node: { node_name.to_sym => asset_name } } }

  AlcesUtils.mock(self, :each) do
    mock_node(node_name)
  end

  def run_command
    Metalware::Utils.run_command(described_class,
                                 asset_name,
                                 node_name,
                                 stderr: StringIO.new)
  end

  it 'errors when the asset does not exist' do
    expect do
      run_command
    end.to raise_error(Metalware::InvalidInput)
  end

  context 'when using a saved asset' do
    before do
      FileSystem.root_setup(&:with_minimal_repo)
    end

    let :asset_path { Metalware::FilePath.asset(asset_name) }
    let :asset_content { { key: 'value' } }

    before :each { Metalware::Data.dump(asset_path, asset_content) } 

    it 'links the asset to a node' do
      run_command
      cache = Metalware::Cache::Asset.new
      expect(cache.data).to eq(content)
    end
  end
end
