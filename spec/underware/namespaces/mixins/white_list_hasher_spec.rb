
# frozen_string_literal: true

require 'underware/namespaces/mixins/white_list_hasher'
require 'ostruct'

RSpec.describe Underware::Namespaces::Mixins::WhiteListHasher do
  let(:whitelist_double) do
    ctx = __binding__
    Class.new do
      include ctx.eval('described_class')

      def self.add_methods(methods)
        methods.each { |m, v| define_method(m) { v } }
      end

      hasher_skip_method
      def do_not_hash_me
        'ohh snap'
      end

      ctx.eval('white_list').each do |method|
        define_method(method) { "#{method} - return" }
      end

      def recursive_hash_obj
        OpenStruct.new(am_i_a_ostuct: 'no, I should be a hash')
      end

      def array_method
        OpenStruct.new(property: 'value_within_array_object')
      end
    end
  end

  let(:test_obj) do
    whitelist_double.add_methods(
      recursive_white_list_for_hasher: recursive_white_list,
      recursive_array_white_list_for_hasher: array_white_list,
    )
    whitelist_double.new
  end

  let(:white_list) { (1..3).map { |i| "white_method#{i}" } }
  let(:recursive_white_list) { ['recursive_hash_obj'] }
  let(:array_white_list) { [:array_method] }

  let(:test_hash) { test_obj.to_h }
  let(:expected_number_of_keys) do
    [
      white_list,
      recursive_white_list,
      array_white_list,
    ].map(&:length).reduce(&:+)
  end

  it 'has all the white listed methods' do
    expect(test_hash.keys).to include(*white_list)
  end

  it 'has the recursive listed methods' do
    expect(test_hash.keys).to include(*recursive_white_list)
  end

  it 'has recursive array listed methods as array of hashes' do
    expect(test_hash.keys).to include(*array_white_list)
    expect(test_hash[:array_method]).to eq [
      { property: 'value_within_array_object' },
    ]
  end

  it 'has the correct number of keys' do
    expect(test_hash.keys.length).to eq(expected_number_of_keys)
  end
end
