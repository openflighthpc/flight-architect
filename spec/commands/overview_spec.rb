# frozen_string_literal: true

require 'commands'
require 'alces_utils'

RSpec.describe Metalware::Commands::Overview do
  include AlcesUtils

  let :overview_yaml do
    {
      group: [
        { header: 'heading1', value: static },
        { header: 'heading2', value: '<%= group.config.key %>' },
        { header: 'heading3', value: '' },
        { header: 'missing-value' },
        { value: 'missing-header' }
      ]
    }
  end
  let :static { 'static' }
  let :headers { overview_yaml[:group].map { |h| h[:header] } }

  let :config_value { 'config_value' }

  AlcesUtils.mock self, :each do
    Metalware::Data.dump Metalware::FilePath.overview, overview_yaml
    ['group1', 'group2', 'group3'].map do |group|
      config(mock_group(group), key: config_value)
    end
  end

  def overview
    std = AlcesUtils.redirect_std(:stdout) do
      Metalware::Utils.run_command(Metalware::Commands::Overview)
    end
    std[:stdout].read
  end

  def header
    overview.lines[1]
  end

  def body
    overview.lines[3..-2].join("\n")
  end

  it 'includes the group names' do
    expect(header).to include('Group')
    alces.groups.each do |group|
      expect(body).to include(group.name)
    end
  end

  it 'includes the headers in the table' do
    headers.each do |h|
      expect(header).to include(h) unless h.nil?
    end
  end

  it 'includes the static value in the table' do
    expect(body).to include(static)
  end

  it 'renders the values' do
    expect(body).to include(config_value)
  end
end

