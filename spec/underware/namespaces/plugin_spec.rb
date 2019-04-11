# frozen_string_literal: true

# =============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Architect.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Architect is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Architect. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Architect, please visit:
# https://github.com/openflighthpc/flight-architect
# ==============================================================================

require 'underware/cluster_attr'

RSpec.describe Underware::Namespaces::Plugin do
  include Underware::AlcesUtils

  subject { described_class.new(plugin, node: node) }

  let(:node) do
    Underware::Namespaces::Node.new(alces, node_name)
  end
  let(:node_name) { 'some_node' }
  let(:node_group_name) { 'some_group' }

  let(:plugin_name) { 'my_plugin' }
  let(:plugin) do
    Underware::Plugins.all.find { |plugin| plugin.name == plugin_name }
  end

  before :each do
    plugins_path = Underware::FilePath.plugins_dir
    plugin_config_dir = File.join(plugins_path, plugin_name, 'config')
    FileUtils.mkdir_p plugin_config_dir

    Underware::ClusterAttr.update(Underware::CommandConfig.new.current_cluster) do |attr|
      attr.add_nodes(node_name, groups: node_group_name)
    end
  end

  describe '#name' do
    it 'returns plugin name' do
      expect(subject.name).to eq 'my_plugin'
    end
  end

  describe '#config' do
    it 'provides access to merged plugin config for node' do
      {
        plugin.domain_config => {
          domain_parameter: 'domain_value',
          group_parameter: 'domain_value',
          node_parameter: 'domain_value',
        },
        plugin.group_config(node_group_name) => {
          group_parameter: 'group_value',
          node_parameter: 'group_value',
        },
        plugin.node_config(node_name) => {
          node_parameter: 'node_value',
        },
      }.each do |plugin_config, config_data|
        Underware::Data.dump(plugin_config, config_data)
      end

      expect(subject.config.domain_parameter).to eq('domain_value')
      expect(subject.config.group_parameter).to eq('group_value')
      expect(subject.config.node_parameter).to eq('node_value')
    end

    it 'supports templating, with access to node namespace values' do
      Underware::Data.dump(plugin.domain_config,
                           node_name: '<%= node.name %>')

      expect(subject.config.node_name).to eq(node.name)
    end
  end
end
