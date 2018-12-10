# frozen_string_literal: true

require 'underware/spec/alces_utils'
require 'underware/cache/asset'

RSpec.describe Underware::Commands::Asset::Link do
  include Underware::AlcesUtils

  let(:asset_name) { 'asset_test' }
  let(:node_name) { 'test_node' }
  let(:node) { alces.nodes.find_by_name(node_name) }
  let(:content) { { node: { node_name.to_sym => asset_name } } }

  Underware::AlcesUtils.mock(self, :each) do
    mock_node(node_name)
  end

  def run_command
    Underware::Utils.run_command(described_class,
                                 node_name,
                                 asset_name,
                                 stderr: StringIO.new)
  end

  it 'errors when the asset does not exist' do
    expect do
      run_command
    end.to raise_error(Underware::MissingRecordError)
  end

  context 'when using a saved asset' do
    Underware::AlcesUtils.mock(self, :each) do
      create_asset(asset_name, {})
    end

    it 'links the asset to a node' do
      run_command
      cache = Underware::Cache::Asset.new
      expect(cache.data).to eq(content)
    end
  end
end
