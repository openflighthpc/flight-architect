# frozen_string_literal: true

require 'spec_utils'
require 'shared_examples/record'
require 'underware/records/layout'

RSpec.describe Underware::Records::Layout do
  include AlcesUtils
  before { allow(Underware::Utils::Editor).to receive(:open) }

  file_path_proc = proc do |types_dir, name|
    Underware::FilePath.layout(types_dir, name)
  end

  let(:valid_path) { Underware::FilePath.layout('rack', 'saved-layout') }
  let(:invalid_path) { Underware::FilePath.asset('server', 'saved-asset') }

  it_behaves_like 'record', file_path_proc
end
