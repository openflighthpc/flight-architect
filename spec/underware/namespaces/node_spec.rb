
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

require 'shared_examples/hash_merger_namespace'
require 'shared_examples/namespace_hash_merging'

require 'underware/namespaces/alces'
require 'underware/constants'
require 'underware/hash_mergers'
require 'recursive_open_struct'

RSpec.describe Underware::Namespaces::Node do
  context 'with AlcesUtils' do
    include Underware::AlcesUtils

    Underware::AlcesUtils.mock self, :each do
      mock_node('test_node')
      mock_group(Underware::AlcesUtils.default_group)
    end

    subject { alces.nodes.first }

    include_examples Underware::Namespaces::HashMergerNamespace
  end

  context 'without AlcesUtils' do
    let(:alces) do
      a = Underware::Namespaces::Alces.new
      allow(a).to receive(:groups).and_return(
        Underware::Namespaces::UnderwareArray.new(
          [
            Underware::Namespaces::Group
              .new(a, 'primary_group', index: primary_group_index),
          ]
        )
      )
      a
    end

    let(:test_value) { 'test value set in namespace/node_spec.rb' }
    let(:primary_group_index) { 'primary_group_index' }
    let(:node_name) { 'node02' }
    let(:node_array) { ['some_other_node', node_name] }

    let(:config_hash) do
      Underware::HashMergers::UnderwareRecursiveOpenStruct.new(
        {
          key: test_value,
          erb_value1: '<%= alces.node.config.key  %>'
        },
        eager_render: alces.eager_render
      ) { |template_string| node.render_string(template_string) }
    end

    let(:node) { described_class.new(alces, node_name) }

    ##
    # Mocks the HashMergers
    #
    before do
      config_double = instance_double(Underware::HashMergers::Config,
                                      merge: config_hash)
      answer_double = instance_double(Underware::HashMergers::Answer,
                                      merge: {})
      allow(Underware::HashMergers::Config).to receive(:new)
        .and_return(config_double)
      allow(Underware::HashMergers::Answer).to receive(:new)
        .and_return(answer_double)

      Underware::ClusterAttr.update(alces.cluster_identifier) do |attr|
        node_array.each { |n| attr.add_nodes(n, groups: 'primary_group') }
      end
    end

    it 'can access the node name' do
      expect(node.name).to eq(node_name)
    end

    it 'can retreive a simple config value for the node' do
      expect(node.config.key).to eq(test_value)
    end

    it 'config parameters can reference other config parameters' do
      expect(node.config.erb_value1).to eq(test_value)
    end

    it 'can find its group index' do
      expect(node.group.index).to eq(primary_group_index)
    end

    it 'can determine the node index' do
      expect(node.index).to eq(2)
    end

    context 'with a mocked ip' do
      let(:ip) { '1.2.3.4' }
      before do
        allow(Underware::DeploymentServer).to receive(:ip).and_return(ip)
      end

      it 'has a kickstart_url' do
        expected = "http://#{ip}/metalware/kickstart/#{node_name}"
        expect(node.kickstart_url).to eq(expected)
      end

      it 'has a build complete url' do
        exp = "http://#{ip}/metalware/exec/kscomplete.php?name=#{node_name}"
        expect(node.build_complete_url).to eq(exp)
      end
    end

    describe '#==' do
      let(:foonode) { described_class.new(alces, 'foonode') }
      let(:barnode) { described_class.new(alces, 'barnode') }

      it 'returns false if other object is not a Node' do
        other_object = Struct.new(:name).new('foonode')
        expect(foonode).not_to eq(other_object)
      end

      it 'defines nodes with the same name as equal' do
        expect(foonode).to eq(foonode)
      end

      it 'defines nodes with different names as not equal' do
        expect(foonode).not_to eq(barnode)
      end
    end
  end

  # Test `#plugins` without the rampant mocking above.
  describe '#plugins' do
    let(:node) { described_class.new(alces, 'node01') }
    let(:alces) { Underware::Namespaces::Alces.new }

    # XXX Need to handle situation of plugin being enabled for node but not
    # available globally?
    let(:enabled_plugin) { 'enabled_plugin' }
    let(:disabled_plugin) { 'disabled_plugin' }
    let(:unconfigured_plugin) { 'unconfigured_plugin' }
    let(:deactivated_plugin) { 'deactivated_plugin' }

    before :each do
      Underware::DataCopy.init_cluster(Underware::CommandConfig.load.current_cluster)

      # Create all test plugins.
      [
        enabled_plugin,
        disabled_plugin,
        unconfigured_plugin,
        deactivated_plugin,
      ].each do |plugin|
        FileUtils.mkdir_p File.join(Underware::FilePath.plugins_dir, plugin)
      end

      # Activate these plugins.
      [
        enabled_plugin,
        disabled_plugin,
        unconfigured_plugin,
      ].each do |plugin|
        Underware::Plugins.activate!(plugin)
      end

      # Enable/disable plugins for node as needed.
      enabled_identifier = \
        Underware::Plugins.enabled_question_identifier(enabled_plugin)
      disabled_identitifer = \
        Underware::Plugins.enabled_question_identifier(disabled_plugin)
      answers = {
        enabled_identifier => true,
        disabled_identitifer => false,
      }.to_json
      Underware::Utils.run_command(
        Underware::Commands::Configure::Node, node.name, answers: answers
      )
    end

    xit 'only includes plugins enabled for node' do
      node_plugin_names = []
      node.plugins.each do |plugin|
        node_plugin_names << plugin.name
      end

      expect(node_plugin_names).to eq [enabled_plugin]
    end

    xit 'uses plugin namespace for each enabled plugin' do
      first_plugin = node.plugins.first

      expect(first_plugin).to be_a(Underware::Namespaces::Plugin)
    end

    xit 'provides access to plugin namespaces by plugin name' do
      plugin = node.plugins.enabled_plugin

      expect(plugin.name).to eq enabled_plugin
    end
  end

  describe 'hash merging' do
    test_node_name = 'testnode01'

    subject do
      described_class.new(alces, 'testnode01')
    end

    context 'when node in genders file' do
      stubbed_groups = ['primary_group', 'additional_group']

      before :each do
        Underware::ClusterAttr.update(Underware::CommandConfig.load.current_cluster) do |attr|
          attr.add_nodes(test_node_name, groups: stubbed_groups)
        end
      end

      include_examples 'namespace_hash_merging',
        description: 'passes own name as `node`, genders as `groups`',
        expected_hash_merger_input: {
          node: test_node_name,
          groups: stubbed_groups
        }
    end
  end
end
