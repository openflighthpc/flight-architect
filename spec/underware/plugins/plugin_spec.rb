
# frozen_string_literal: true

RSpec.describe Underware::Plugins::Plugin do
  subject { described_class.new(plugin_dir_path) }

  let(:plugin_dir_path) { Pathname.new('/path/to/some-plugin') }

  describe '#enabled_question_identifier' do
    it 'gives correct identifier for generated plugin enabled question' do
      expect(
        subject.enabled_question_identifier
      ).to eq 'underware_internal--plugin_enabled--some-plugin'
    end
  end

  it 'gives correct path for each path method' do
    expect(
      subject.domain_config
    ).to eq("#{plugin_dir_path}/config/domain.yaml")
    expect(
      subject.group_config('some_group')
    ).to eq("#{plugin_dir_path}/config/some_group.yaml")
    expect(
      subject.group_config('some_node')
    ).to eq("#{plugin_dir_path}/config/some_node.yaml")
  end
end
