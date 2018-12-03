
# frozen_string_literal: true

require 'underware/hash_mergers'
require 'underware/data'
require 'underware/constants'
require 'underware/spec/alces_utils'

RSpec.describe Underware::HashMergers::HashMerger do
  include Underware::AlcesUtils

  Underware::AlcesUtils.mock self, :each do
    validation_off
  end

  before :each do
    fp = Underware::FilePath

    FileSystem.root_setup do |fs|
      fs.with_minimal_configure_file

      dump_data = lambda do |data, config_path, answers_path|
        [config_path, answers_path].each do |path|
          fs.dump(path, data)
        end
      end

      # We set up various simple, identical data files for both configs and
      # answers at different levels, so we can test that merging works
      # correctly for both config and answer HashMergers.
      dump_data.call(domain_data, fp.domain_config, fp.domain_answers)
      dump_data.call(group1_data, fp.group_config('group1'), fp.group_answers('group1'))
      dump_data.call(group2_data, fp.group_config('group2'), fp.group_answers('group2'))
      dump_data.call(node3_data, fp.node_config('node3'), fp.node_answers('node3'))
    end
  end

  let :domain_data do
    {
      value0: 'domain',
      value1: 'domain',
      value2: 'domain',
      value3: 'domain',
    }
  end

  let :group1_data do
    {
      value2: 'group1',
      value3: 'group1',
    }
  end

  let :group2_data do
    {
      value1: 'group2',
      value2: 'group2',
      value3: 'group2',
    }
  end

  let :node3_data do
    {
      value3: 'node3',
    }
  end

  let :merged_namespace do
    hm = Underware::HashMergers
    OpenStruct.new(
      config: hm::Config.new.merge(**hash_input, &:itself),
      answer: hm::Answer.new(alces).merge(**hash_input, &:itself)
    )
  end

  context 'with domain scope' do
    let :hash_input { {} }

    it 'correctly merges config (which is identical to domain config)' do
      expect(merged_namespace.config.to_h).to eq(domain_data)
    end
  end

  context 'with single group' do
    let :hash_input do
      {groups: ['group2']}
    end

    it 'correctly merges config' do
      expect(merged_namespace.config.to_h).to eq(
        value0: 'domain',
        value1: 'group2',
        value2: 'group2',
        value3: 'group2',
      )
    end
  end

  context 'with multiple groups' do
    let :hash_input do
      {groups: ['group1', 'group2']}
    end

    it 'correctly merges config' do
      expect(merged_namespace.config.to_h).to eq(
        value0: 'domain',
        value1: 'group2', # Not set for group1 so group2's value used.
        value2: 'group1',
        value3: 'group1',
      )
    end
  end

  context 'with multiple groups and a node' do
    let :hash_input do
      {
        groups: ['group1', 'group2'],
        node: 'node3'
      }
    end

    let :expected_merged_data do
      {
        value0: 'domain',
        value1: 'group2',
        value2: 'group1',
        value3: 'node3',
      }
    end

    it 'correctly merges config' do
      expect(merged_namespace.config.to_h).to eq(expected_merged_data)
    end

    it 'correctly merges answers' do
      expect(merged_namespace.answer.to_h).to eq(expected_merged_data)
    end
  end
end
