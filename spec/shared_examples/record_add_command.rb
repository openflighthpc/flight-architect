# frozen_string_literal: true

require 'underware/spec/alces_utils'

RSpec.shared_examples 'record add command' do
  include Underware::AlcesUtils
  # Stops the editor from running the bash command
  before { allow(Underware::Utils::Editor).to receive(:open) }

  let(:type) { 'rack' }
  let(:saved_record_name) { 'saved-record' }

  context 'when using the rack type' do
    before { FileSystem.setup(&:with_asset_types) }

    let(:type_path) { Underware::FilePath.asset_type(type) }

    def run_command(record_name = saved_record_name)
      Underware::Utils.run_command(described_class,
                                   type,
                                   record_name,
                                   stderr: StringIO.new)
    end

    it 'calls for the record to be opened and copied' do
      expect(Underware::Utils::Editor).to receive(:open_copy)
        .with(type_path, record_path)
      run_command
    end

    it 'errors if the record already exists' do
      run_command
      expect do
        run_command
      end.to raise_error(Underware::InvalidInput)
        .with_message(/already exists/)
    end

    it 'errors if the record name is an asset type' do
      expect do
        run_command(type)
      end.to raise_error(Underware::InvalidInput)
        .with_message(/is not a valid/)
    end
  end

  context 'with a layout' do
    Underware::AlcesUtils.mock(self, :each) do
      create_layout(layout, {})
    end

    let(:layout) { 'rack-layout' }
    let(:layout_path) { Underware::FilePath.layout(type.pluralize, layout) }

    def run_command(record_name = saved_record_name)
      Underware::Utils.run_command(described_class,
                                   layout,
                                   record_name,
                                   stderr: StringIO.new)
    end

    it 'calls for the record to be opened and copied' do
      expect(Underware::Utils::Editor).to receive(:open_copy)
        .with(layout_path, record_path)
      run_command
    end
  end
end
