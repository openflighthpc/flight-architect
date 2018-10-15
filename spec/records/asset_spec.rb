# frozen_string_literal: true

require 'spec_utils'
require 'shared_examples/record'

RSpec.describe Underware::Records::Asset do
  file_path_proc = proc do |types_dir, name|
    Underware::FilePath.asset(types_dir, name)
  end

  let(:valid_path) { Underware::FilePath.asset('rack', 'saved-asset') }
  let(:invalid_path) { Underware::FilePath.layout('server', 'saved-layout') }

  it_behaves_like 'record', file_path_proc
end
