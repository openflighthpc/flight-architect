# frozen_string_literal: true

require 'underware/cache/asset'
require 'underware/commands'
require 'underware/utils'
require 'underware/spec/alces_utils'

RSpec.describe Underware::Commands::Asset::Delete do
  include Underware::AlcesUtils
  let(:asset) { 'saved-asset' }

  def run_command
    Underware::Utils.run_command(described_class,
                                 asset,
                                 stderr: StringIO.new)
  end

  it 'errors if the asset does not exist' do
    expect do
      run_command
    end.to raise_error(Underware::MissingRecordError)
  end

  context 'when using a saved asset' do
    Underware::AlcesUtils.mock(self, :each) do
      create_asset(asset, {})
    end

    it 'deletes the asset file' do
      run_command
      expect(Underware::Records::Asset.path(asset)).to be_nil
    end
  end
end