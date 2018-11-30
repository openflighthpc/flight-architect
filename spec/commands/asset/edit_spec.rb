# frozen_string_literal: true

require 'underware/commands'
require 'underware/utils'
require 'shared_examples/asset_command_that_assigns_a_node'
require 'shared_examples/record_edit_command'
require 'underware/spec/alces_utils'

RSpec.describe Underware::Commands::Asset::Edit do
  include Underware::AlcesUtils
  before { allow(Underware::Utils::Editor).to receive(:open) }

  let(:record_name) { 'asset' }
  let(:record_path) { Underware::Records::Asset.path(record_name) }

  Underware::AlcesUtils.mock(self, :each) do
    create_asset(record_name, {})
  end

  it_behaves_like 'record edit command'

  context 'with a node input' do
    let(:asset_name) { 'asset1' }
    let(:command_arguments) { [asset_name] }

    Underware::AlcesUtils.mock(self, :each) do
      create_asset(asset_name, {})
    end
    it_behaves_like 'asset command that assigns a node'
  end
end
