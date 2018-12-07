# frozen_string_literal: true

require 'underware/spec/alces_utils'
require 'shared_examples/record_edit_command'

RSpec.describe Underware::Commands::Layout::Edit do
  include Underware::AlcesUtils
  before { allow(Underware::Utils::Editor).to receive(:open) }

  let(:record_name) { 'layout' }
  let(:record_path) { Underware::Records::Layout.path(record_name) }

  Underware::AlcesUtils.mock(self, :each) do
    create_layout(record_name, {})
  end

  it_behaves_like 'record edit command'
end
