
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

  def build_merged_hash(**hash_input)
    hm = Underware::HashMergers
    OpenStruct.new(
      config: hm::Config.new.merge(**hash_input, &:itself),
      answer: hm::Answer.new(alces).merge(**hash_input, &:itself)
    )
  end

  def expect_config_value(my_hash)
    expect(my_hash.config.to_h).not_to be_empty
    my_hash.config.to_h.each do |key, value|
      expect(value).to eq(yield key)
    end
  end

  context 'with domain scope' do
    let(:merged_hash) { build_merged_hash }

    it 'returns the domain config' do
      expect_config_value(merged_hash) { 'domain' }
    end
  end

  context 'with single group' do
    let(:merged_hash) do
      build_merged_hash(groups: ['group2'])
    end

    it 'returns the merged configs' do
      expect_config_value(merged_hash) do |key|
        case key
        when :value0
          'domain'
        else
          'group2'
        end
      end
    end
  end

  context 'with multiple groups' do
    let(:merged_hash) do
      build_merged_hash(groups: ['group1', 'group2'])
    end

    it 'returns the merged configs' do
      expect_config_value(merged_hash) do |key|
        case key
        when :value0
          'domain'
        when :value1
          'group2'
        else
          'group1'
        end
      end
    end
  end

  context 'with multiple groups and a node' do
    let(:merged_hash) do
      build_merged_hash(
        groups: ['group1', 'group2'],
        node: 'node3'
      )
    end

    def check_node_hash(my_hash = {})
      expect(my_hash).not_to be_empty
      my_hash.each do |key, value|
        expected_value = case key
                         when :value0
                           'domain'
                         when :value1
                           'group2'
                         when :value2
                           'group1'
                         else
                           'node3'
                         end
        expect(value).to eq(expected_value)
      end
    end

    it 'returns the merged configs' do
      check_node_hash(merged_hash.config.to_h)
    end

    it 'returns the correct answers' do
      check_node_hash(merged_hash.answer.to_h)
    end
  end
end
